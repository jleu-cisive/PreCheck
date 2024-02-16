-- =============================================
-- Author: Deepak Vodethela
-- Requester: Charles Sours
-- Create date: 02/16/2016
-- Modified by: Prasanna HDT#72797 add 2 columns "returned Disposition", "Final Disposition"
-- Modified by Humera Ahmed on 10/19/2020 for HDT##79625 Adding new column vendor entered date/time
-- Description:	To get the details of Criminal Hit Search by county Name
-- Execution: EXEC [dbo].[Criminal_Hit_Search_by_County_Name]  '01/10/2011', '02/12/2016','Baxter','Clear'
--			  EXEC [dbo].[Criminal_Hit_Search_by_County_Name]  '01/01/2019', '12/31/2019','**Statewide**, AL','Record Found'
--			  EXEC [dbo].[Criminal_Hit_Search_by_County_Name]  '05/11/2020', '05/15/2020','NUECES, TX','Record Found'
--Modified by Vidya Jha on 02/22/2023 for HDT 83957
--Modified by Vidya Jha to add 'ZC Case Number' column
-- =============================================
CREATE PROCEDURE [dbo].[Criminal_Hit_Search_by_County_Name]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@County varchar(50),
	@Status varchar(40) 
AS
SET NOCOUNT ON

IF Len(LTRIM(RTRIM(@Status))) = 0 
	SET @Status = Null

	SELECT Appl.APNO as 'APP #', C.CRIMID, isnull(Appl.[Last],'') +' '+ isnull(Appl.[First],'') +' '+ isnull(Appl.[Middle],'') AS ApplicantName,
	Appl.DOB AS DOB, Appl.SSN AS SSN, isnull(C.[Name],'') AS [Name On Record], C.[DOB] AS [DOB On Record],C.SSN AS [SSN On Record],c.Pub_Notes, c.County, c.clear, 
	cs.crimdescription AS [Status], c.Degree,c.Offense,c.Sentence,c.Disp_Date,c.Crimenteredtime
	, case when C.deliverymethod <> 'web service' then max(cv.EnteredDate)
		   else 
				  case when  max(i.updated_on) is null then max(C.Crimenteredtime)
				  else DATEADD(hh, -7,  max(i.updated_on) ) -- utc time conversion to cst
				  end
	   end as 'Vendor entered'
	, c.Disposition as [Returned Disposition], rd.disposition as [Final Disposition]
	, case when c.IsHidden = 0 then 'False'
			when c.IsHidden=1 then 'True'
			end as 'Is In Unused'
	,c.CaseNo as 'Case Number'	
	,zcwos.PartnerReference as 'ZC Case Number'
	FROM Crim AS C WITH (NOLOCK)
	LEFT JOIN RefDisposition RD WITH(NOLOCK) ON RD.RefDispositionID = C.RefDispositionID
	INNER JOIN Crimsectstat AS CS WITH(NOLOCK) ON CS.crimsect = C.[Clear]
	INNER JOIN Appl AS Appl WITH(NOLOCK) ON Appl.APNO = c.APNO
	left outer join iris_ws_screening i   on C.CrimID = i.crim_id
	left outer join CriminalVendor_Log cv on C.apno = cv.apno and c.cnty_no = cv.CNTY_NO
	left join [dbo].[ZipCrimWorkOrders] zcwo on zcwo.APNO=C.APNO
	left join  [dbo].[ZipCrimWorkOrdersStaging] zcwos on zcwo.WorkOrderID=zcwos.WorkOrderID
	WHERE c.APNO >='1000000' 
	  AND C.clear in ('T','P','F') 
	  AND C.County LIKE '%' + @county + '%'
	  AND (C.Crimenteredtime BETWEEN @StartDate and DATEADD(d,1,@EndDate))
	  AND (@Status IS NULL OR CS.crimdescription LIKE '%' + @Status + '%')
  		--AND Ishidden = 0
		GROUP BY Appl.APNO, C.CRIMID, Appl.Last, Appl.First, Appl.Middle, Appl.DOB, Appl.SSN, C.Name, C.DOB, C.SSN, c.Pub_Notes, c.County, c.clear, 
	cs.crimdescription, c.Degree,c.Offense,c.Sentence,c.Disp_Date,c.Crimenteredtime, C.deliverymethod, c.Disposition, rd.disposition,c.IsHidden,c.CaseNo,zcwos.PartnerReference
	ORDER BY C.crimenteredtime DESC
