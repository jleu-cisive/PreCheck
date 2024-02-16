-- Alter Procedure Iris_Orders_By_DeliveryMethod

/*
Edited By	:	Deepak Vodethela	
Edited date	:	02/09/2017
Description	:	As part of Alias Logic Re-Write project all the Aliases will be from dbo.ApplAlias (Overflow table). Modified the conditions at Aliases section.
Execution : 
	EXEC [dbo].[Iris_Orders_By_DeliveryMethod] 'fax-copyofcheck'
	EXEC [dbo].[Iris_Orders_By_DeliveryMethod] 'Mail-copyofcheck'
	EXEC [dbo].[Iris_Orders_By_DeliveryMethod] 'mail'
*/

CREATE PROCEDURE [dbo].[Iris_Orders_By_DeliveryMethod]
@DeliveryMethod NVARCHAR(100) NULL
AS
	-- This script is to return the devivery method records
	SELECT	A.R_Name,
			A.R_Firstname,
			A.b_rule,
			A.R_Lastname,
			case when sum(A.readytosend) < count(A.readytosend) then 0
			else 1 end as readytosend,
			A.vendorid,
			A.R_Delivery,
			A.CNTY_NO,
			MIN(A.crim_time) AS crim_time,
			A.county, 
			A.State,
			A.IRIS_REC
	FROM 
	(
	SELECT   DISTINCT IR.R_Name, 
			 IR.R_Firstname, 
			 C.b_rule, 
			 IR.R_Lastname,
			 CASE WHEN ((CASE WHEN irc.Researcher_Aliases_count = 'All' THEN 5 ELSE irc.Researcher_Aliases_count END) >= Y.AliasCount
					   ) THEN 1 ELSE 0 END AS ReadyToSend,
			 IR.R_id AS vendorid, 
			 IR.R_Delivery, 
			 C.CNTY_NO,
			 (SELECT MIN(z.crimenteredtime)
				FROM Crim z
			   WHERE (z.cnty_no = C.cnty_no) 
				 AND (z.Clear IS NULL or z.clear = 'R') 
				 AND (z.iris_rec = 'yes')) AS crim_time, 
			 X.A_County AS county, 
			 X.State, 
			 C.IRIS_REC
	FROM dbo.Crim AS C WITH (NOLOCK) 
	INNER JOIN dbo.TblCounties AS X WITH (NOLOCK) ON C.CNTY_NO = X.CNTY_NO 
	INNER JOIN dbo.Appl AS A WITH (NOLOCK) ON C.APNO = A.APNO
	INNER JOIN (SELECT APNO, COUNT(1) AS AliasCount FROM dbo.ApplAlias(NOLOCK) WHERE IsPublicRecordQualified = 1 GROUP BY APNO) AS Y ON A.APNO = Y.APNO
	INNER JOIN dbo.ApplAlias AS AA(NOLOCK) ON A.APNO = AA.APNO AND AA.IsPublicRecordQualified = 1 --AND AA.IsPrimaryName = 0
	LEFT OUTER JOIN dbo.Iris_Researchers AS IR WITH (NOLOCK) ON C.vendorid = IR.R_id
	LEFT OUTER JOIN dbo.Iris_Researcher_Charges AS IRC WITH (NOLOCK)ON IR.R_id = IRC.Researcher_id AND C.CNTY_NO = IRC.cnty_no
	WHERE (IR.R_Delivery = @DeliveryMethod) 
	  AND (C.Clear IS NULL or C.clear = 'R') 
	  AND (C.IRIS_REC = 'yes') 
	  AND (C.batchnumber IS NULL)  
	  AND (DATEDIFF(mi, C.Crimenteredtime, GETDATE()) >= 1) 
	  AND (A.InUse IS NULL )
	  AND A.CLNO not in (3468) 
	  AND (C.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
	)A
	GROUP BY A.R_Name,
			 A.R_Firstname,
			 A.b_rule,
			 A.R_Lastname,
			 A.vendorid,
			 A.R_Delivery,
			 A.CNTY_NO,
			 A.county, 
			 A.State,
			 A.IRIS_REC
	ORDER BY crim_time asc, CASE WHEN SUM(A.readytosend) < COUNT(A.readytosend) THEN 0 ELSE 1 END

	-- This below script's are for devivery method's and used to Insert into ApplAlias_Sections for logging and updating the Crim table for ReadyToSend 
	CREATE TABLE #IrisAliasUpdate (
		CrimID int,-- PRIMARY KEY CLUSTERED,
		APNO int,
		ApplAliasID int,
		ReadyToSend bit,
		ReadyToSend_Old bit,
		ApStatus char(1), 
		Iris_Rec varchar(3), 
		Clear varchar(1), 
		Clear_Old varchar(1),
		BatchNumber float, 
		BatchNumber_Old float,
		DeliveryMethod varchar(50), 
		CrimEnteredTime datetime
	)

	INSERT INTO #IrisAliasUpdate (
		CrimID,
		APNO,
		ApplAliasID,
		ReadyToSend,
		ReadyToSend_Old,
		ApStatus, 
		Iris_Rec, 
		Clear, 
		Clear_Old,
		BatchNumber, 
		BatchNumber_Old,
		DeliveryMethod, 
		CrimEnteredTime)

	SELECT  c.CrimID,
			A.apno,
			AA.ApplAliasID,
			 CASE WHEN ((CASE WHEN irc.Researcher_Aliases_count = 'All' THEN 5 ELSE irc.Researcher_Aliases_count END) >= Y.AliasCount
					   ) THEN 1 ELSE 0 END AS ReadyToSend,
			c.ReadyToSend AS ReadyToSend_Old,
			a.apstatus AS ApStatus, 
			c.iris_rec AS Iris_Rec, 
			'' AS Clear, 
			c.clear AS Clear_Old,
			0 AS BatchNumber, 
			c.batchnumber AS BatchNumber_Old, 
			c.deliverymethod AS DeliveryMethod, 
			c.Crimenteredtime AS CrimEnteredTime
	FROM dbo.Crim AS c(NOLOCK) 
	INNER JOIN dbo.TblCounties AS ct(NOLOCK) ON c.CNTY_NO = ct.CNTY_NO 
	INNER JOIN dbo.appl AS A(NOLOCK) ON c.apno = a.apno
	INNER JOIN (SELECT APNO, COUNT(1) AS AliasCount FROM dbo.ApplAlias(NOLOCK) WHERE IsPublicRecordQualified = 1 GROUP BY APNO) AS Y ON A.APNO = Y.APNO
	INNER JOIN dbo.ApplAlias AS AA(NOLOCK) ON A.APNO = AA.APNO AND AA.IsPublicRecordQualified = 1
	LEFT OUTER JOIN dbo.Iris_Researchers AS ir(NOLOCK) ON c.vENDORid = ir.R_id 
	LEFT OUTER JOIN dbo.Iris_Researcher_Charges AS irc(NOLOCK) ON irc.Researcher_id = ir.R_id AND c.CNTY_NO = irc.cnty_no
	WHERE (ir.R_Delivery = @DeliveryMethod) 
	  AND (c.Clear IS NULL or c.clear = 'R') 
	  AND (c.IRIS_REC = 'yes') 
	  AND (c.batchnumber IS NULL) 
	  AND (DATEDIFF(mi, c.last_updated, GETDATE()) >= 1)  
	  AND (a.InUse IS NULL ) 
	  AND (c.readytosend=0)

  	--SELECT * FROM #IrisAliasUpdate order by 1 desc

	-- Get all the Unique Qualified Records
	SELECT CrimID, APNO, ReadyToSend, ReadyToSend_Old, ApStatus, Iris_Rec,Clear, Clear_Old, BatchNumber,BatchNumber_Old,DeliveryMethod,CrimEnteredTime
			INTO #UniqueAliasesSent
	FROM #IrisAliasUpdate 
	GROUP BY CrimID, APNO, ReadyToSend, ReadyToSend_Old, ApStatus, Iris_Rec,Clear, Clear_Old, BatchNumber,BatchNumber_Old,DeliveryMethod,CrimEnteredTime
	ORDER BY 1 DESC
	
	--SELECT * FROM #UniqueAliasesSent

	-- Insert into ApplAlias_Sections when these records are Sent by Winservice i.e. when count is set to all
	INSERT INTO [dbo].[ApplAlias_Sections]([ApplSectionID],[SectionKeyID],[ApplAliasID],[IsActive],[CreateDate],[CreatedBy],[LastUpdateDate],[LastUpdatedBy])
		SELECT 5 , CrimID , ApplAliasID, 1 , CURRENT_TIMESTAMP , @DeliveryMethod, CURRENT_TIMESTAMP , @DeliveryMethod FROM #IrisAliasUpdate WHERE ReadyToSend = 1 		

	-- Insert into Audit Log - Dependencies
	INSERT INTO IrisAliasUpdate_AutoCheck_Log
				(CrimID,
				ReadyToSend,
				ReadyToSend_Old,
                txtlast,
                txtlast_old,
                txtalias,
                txtalias_old,
                txtalias2,
                txtalias2_old,
                txtalias3,
                txtalias3_old,
                txtalias4,
                txtalias4_old, 
                ApStatus, 
				Iris_Rec, 
				Clear, 
				Clear_Old,
				BatchNumber, 
				BatchNumber_Old,
				DeliveryMethod,
				CrimEnteredTime,
				InsertTimeStamp)
        SELECT	CrimID,
				ReadyToSend,
				ReadyToSend_Old,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0, 
                ApStatus, 
				Iris_Rec, 
				Clear, 
				Clear_Old,
				BatchNumber, 
				BatchNumber_Old,
				DeliveryMethod,
				CrimEnteredTime,
				CURRENT_TIMESTAMP
		FROM #UniqueAliasesSent 
		WHERE ReadyToSend = 1 

	UPDATE dbo.Crim 
		SET ReadyToSend = a.ReadyToSend
	FROM dbo.Crim AS c 
	INNER JOIN #UniqueAliasesSent a ON a.Crimid = c.Crimid
	WHERE a.ReadyToSend = 1  

	DROP TABLE #IrisAliasUpdate
	DROP TABLE #UniqueAliasesSent
