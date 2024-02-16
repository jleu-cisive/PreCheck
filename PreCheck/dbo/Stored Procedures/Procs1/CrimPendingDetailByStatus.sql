

-- =============================================
-- Author: Radhika Dereddy
-- Create date: unknown
-- Modified Date: 06/19/2018
-- Description:	Add a new column called Vendor to the stored Procedure. 
-- EXEC [CrimPendingDetailByStatus]'V'
-- Modified by: Radhika Dereddy on 09/04/2018 - Add Affiliate column to the procedure
-- Modified by: Radhika Dereddy on 06/24/2019 - Add PrivateNotes 
--[dbo].[CrimPendingDetailByStatus] 'V'
-- Modified by Radhika Dereddy on 06/11/2020 - Added this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) 
-- and many of more so adding the max length of the excel to accommodate the export.
-- Modified by Prasanna on 06/26/2020 - HDT#74420: Add column for ETA
-- Modified by Humera Ahmed on 12/02/2020 - HDT#81815: Please add a column for Public Notes, just before the existing Private Notes column
-- Modified by Prasanna on 10/21/2021 - HDT#23236 Add Zipcrim work order id column
-- Modified by Vidya Jha on 06/16/2022 - HDT#21336 Add PartnerReference column using inner join dbo.ZipCrimWorkOrdersStaging
-- Modified by Shashank Bhoi on 11/08/2023 HDT #116352 Crim Pending Detail by Status Add Columns
-- Modified by Arindam Mitra on 11/16/2023 HDT #117238 Query optimized since data was fetching slowly
-- Modified by Cameron DeCook on 1/29/2024  HDT #124917 Query optimized since data was fetching slowly
-- =========================================================================
CREATE PROCEDURE [dbo].[CrimPendingDetailByStatus] --'V'
    -- Add the parameters for the stored procedure here
    @CrimStatus VARCHAR(50) = ''
AS
BEGIN

    IF @CrimStatus IS NULL
       OR @CrimStatus = 'NULL'
       OR @CrimStatus = 'null'
    BEGIN
        SET @CrimStatus = '';
    END;

    IF OBJECT_ID('tempdb..#CPDStemp') IS NOT NULL
        DROP TABLE #CPDStemp;

    SELECT A.APNO,
           zcwos.PartnerReference AS CaseNo,
           c.CrimID,
           A.UserID CAM,
           rf.Affiliate [Affiliate Name],
           cl.CLNO [Client ID],
           cl.Name [Client Name],
           A.ApDate,
           A.ApStatus,
           A.Last,
           A.First,
           '"' + c.County + '"' county,
           c.CNTY_NO,
           ir.R_Name AS 'Vendor',
           c2.crimsect + '-' + c2.crimdescription AS 'crimstatus',
           c.Crimenteredtime AS CrimEnteredTime,
           c.Ordered AS CrimOrderedDateTime,
           c.Last_Updated,
           c.deliverymethod,
           CASE
               WHEN c.deliverymethod <> 'web service' THEN
                   MAX(cv.EnteredDate)
               ELSE
                   CASE
                       WHEN MAX(i.updated_on) IS NULL THEN
                           MAX(c.Crimenteredtime)
                       ELSE
                           DATEADD(hh, -7, MAX(i.updated_on)) -- utc time conversion to cst
                   END
           END AS 'Vendor entered',
           CONVERT(NUMERIC(7, 2), dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE())) AS [Elapsed],
           c.Pub_Notes AS 'Public Notes',
           REPLACE(REPLACE(LEFT(c.Priv_Notes, 32766), CHAR(10), ';'), CHAR(13), ';') AS 'Private Notes',
           ase.ETADate AS ETA,
           ISNULL(x.HitCount, 1) AS HitCount,
           zcwo.WorkOrderID
    INTO #CPDStemp
    FROM Appl AS A WITH (NOLOCK)
        INNER JOIN Crim AS c WITH (NOLOCK)
            ON A.APNO = c.APNO
        LEFT JOIN dbo.ZipCrimWorkOrders AS zcwo WITH (NOLOCK)
            ON zcwo.APNO = A.APNO
        LEFT OUTER JOIN
        (
            SELECT cr.CrimID,
                   COUNT(cr.CrimID) AS HitCount
            FROM dbo.Crim_Review cr WITH (NOLOCK)
            GROUP BY cr.CrimID
        ) AS x
            ON c.CrimID = x.CrimID
        LEFT JOIN ApplSectionsETA AS ase WITH (NOLOCK)
            ON ase.Apno = c.APNO
               AND ase.SectionKeyID = c.CrimID
        INNER JOIN Iris_Researchers AS ir WITH (NOLOCK)
            ON c.vendorid = ir.R_id
        LEFT OUTER JOIN iris_ws_screening AS i WITH (NOLOCK)
            ON c.CrimID = i.crim_id
        LEFT OUTER JOIN CriminalVendor_Log AS cv WITH (NOLOCK)
            ON c.APNO = cv.APNO
               AND c.CNTY_NO = cv.CNTY_NO
        INNER JOIN Client AS cl WITH (NOLOCK)
            ON A.CLNO = cl.CLNO
        INNER JOIN refAffiliate AS rf WITH (NOLOCK)
            ON cl.AffiliateID = rf.AffiliateID
        INNER JOIN dbo.Crimsectstat AS c2 WITH (NOLOCK)
            ON c.Clear = c2.crimsect
        LEFT OUTER JOIN dbo.ZipCrimWorkOrdersStaging AS zcwos WITH (NOLOCK)
            ON zcwos.WorkOrderID = zcwo.WorkOrderID
    WHERE ISNULL(A.ApStatus, 'P') IN ( 'P', 'W' )
          AND ISNULL(c.Clear, '') NOT IN ( 'F', 'T', 'P', 'A', 'C', 'S' )
          AND c.IsHidden = 0
          AND ISNULL(c.Clear, '') LIKE ('%' + @CrimStatus + '%')
          AND LEN(REPLACE(REPLACE(LEFT(c.Priv_Notes, 32766), CHAR(10), ';'), CHAR(13), ';')) < 32767 --Added by Radhika Dereddy on 06/11/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.
    GROUP BY A.APNO,
             A.UserID,
             A.ApDate,
             A.ApStatus,
             A.SSN,
             A.Last,
             A.First,
             c.County,
             c.CNTY_NO,
             c.Clear,
             c.deliverymethod,
             c.CrimID,
             A.DOB,
             c.IrisOrdered,
             c.Crimenteredtime,
             c.Ordered,
             c.Last_Updated,
             ir.R_Name,
             c2.crimsect + '-' + c2.crimdescription,
             rf.Affiliate,
             cl.CLNO,
             cl.Name,
             A.ReopenDate,
             c.Priv_Notes,
             ase.ETADate,
             x.HitCount,
             c.Pub_Notes,
             zcwo.WorkOrderID,
             zcwos.PartnerReference;


    SELECT ca.*,
           OJ.JobStartDate AS [Orientation Date],
           CASE
               WHEN CHARINDEX('@', A.Attn) > 1 THEN
                   A.Attn
               ELSE
                   CC1.Email
           END AS [Attn :]
    --FROM cteA AS CA
    FROM #CPDStemp ca
        INNER JOIN dbo.Appl A WITH (NOLOCK)
            ON A.APNO = ca.APNO

        /*---------Code commented against HDT# 117238
	OUTER APPLY (
		SELECT OJ.JobStartDate 
		FROM Enterprise.[dbo].[Order] AS O  (Nolock) 
		INNER join Enterprise.[dbo].[OrderJobDetail] AS OJ  (Nolock) on o.[OrderId]=oj.orderid 
		WHERE CA.Apno = ordernumber AND OJ.JobStartDate IS NOT NULL
	) AS OJ1
	*/

        ----code added starts against HDT# 117238
        --LEFT JOIN (  
        --	  SELECT DISTINCT OJ.JobStartDate, O.OrderNumber, CrimID   
        --	  FROM Enterprise.[dbo].[Order] AS O  (NOLOCK)   
        --	  INNER JOIN Enterprise.[dbo].[OrderJobDetail] AS OJ  (NOLOCK) ON o.[OrderId]=oj.orderid  
        --	  INNER JOIN CRIM AS C  (NOLOCK) ON C.APNO=o.ordernumber  
        --	  WHERE OJ.JobStartDate IS NOT NULL  AND ISNULL(clear,'') LIKE ('%' + @CrimStatus + '%')  AND c.ishidden = 0
        --	 ) AS OJ1 ON CA.APNO=OJ1.ORDERNUMBER AND CA.CrimID = OJ1.CrimID
        ----code added ends against HDT# 117238

        OUTER APPLY
    (
        SELECT TOP 1
               Email,
               FirstName,
               LastName
        FROM ClientContacts CC WITH (NOLOCK)
        WHERE CC.CLNO = A.CLNO
              AND CAST(A.Attn AS NVARCHAR) = (CC.LastName + ', ' + CC.FirstName)
              AND IsActive = 1
        ORDER BY 1 DESC
    ) AS CC1
        LEFT OUTER JOIN Enterprise.[dbo].[Order] AS O WITH (NOLOCK)
            ON ca.APNO = O.OrderNumber
        LEFT OUTER JOIN Enterprise.[dbo].[OrderJobDetail] AS OJ WITH (NOLOCK)
            ON O.[OrderId] = OJ.OrderId
    ORDER BY ca.APNO ASC;
END;
