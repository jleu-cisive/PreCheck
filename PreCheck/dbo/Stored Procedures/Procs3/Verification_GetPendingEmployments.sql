


--[Verification_GetPendingEmployments] 'SJV'

/***************************************************************************
* Procedure Name: [dbo].[Verification_GetPendingEmployments]
* Created By: Doug DeGenaro
* Created On: 7/11/2012 1:18 PM
*****************************************************************************/

/***************************************************************************
* Procedure Name: [dbo].[Verification_GetPendingEmployments]
* Updated By: Doug DeGenaro
* Updated On: 7/11/2012 1:18 PM
* Description : Changed when @vendor is null, then use 'REFPRO'
*****************************************************************************/
/***************************************************************************
* Procedure Name: [dbo].[Verification_GetPendingEmployments]
* Updated By: Sahithi Gangaraju
* Updated On: 05/09/2019 11:00 AM
* Description : Added Alias names by joining with ApplAlias table and new column NoemplPassThru
--inner JOIN ApplAlias AS AA(NOLOCK) ON AA.APNO = e.Apno (removed as causing duplicates 5/12/2019)
-- added for alias names as on 05-09-2019 --Removed as not needed to join 
--inner JOIN ApplAlias AS AA(NOLOCK) ON AA.APNO = a.APNO
--where a.RowNumber = 1( Removed as its excluding empl records for same apno 5/12/2019)

*****************************************************************************/
/***************************************************************************
* Procedure Name: [dbo].[Verification_GetPendingEmployments]
* Updated By: Dongmei He
* Updated On: 03/27/2023
* Description : add affilate name and client name for the request to ZipCrim and SJV
* Updated By: Dongmei He
* Updated On: 04/05/2023
* Description : add CallerLocation
*****************************************************************************/
--[dbo].[Verification_GetPendingEmployments] 'SJV'

CREATE procedure [dbo].[Verification_GetPendingEmployments] 
(@vendor varchar(30) = null)

AS
BEGIN
	SET NOCOUNT ON;  
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


	

	CREATE TABLE #tmpOrders(	
	SectionKeyId int,
	AffiliateName Varchar(50),
	CallerLocation VARCHAR(50)
	)

	CREATE CLUSTERED INDEX IX_tmpOrders_01 ON #tmpOrders(SectionKeyId);

	
		insert into #tmpOrders
	select  distinct e.EmplID, ref.Affiliate as AffiliateName,
	CASE WHEN cg.GroupCode = 6 THEN 'Onshore' 
	     WHEN  cg.GroupCode = 7 THEN 'Offshore' 
	ELSE 'All' END as CallerLocation
	FROM dbo.empl e  WITH (NOLOCK) INNER JOIN dbo.appl a WITH (NOLOCK) 
		ON a.apno = e.apno
	INNER JOIN dbo.client c on c.CLNO = a.CLNO
	inner join refaffiliate ref on ref.affiliateid = c.affiliateid
	LEFT JOIN ClientGroup cg on cg.CLNO = c.CLNO 
	and cg.GroupCode in(6, 7)
	and cg.IsActive = 1
	-- added for alias names as on 05-09-2019 
	--inner JOIN ApplAlias AS AA(NOLOCK) ON AA.APNO = a.APNO
	WHERE e.sectstat in ('9') and IsNull(web_status,0) = 0 
	and dateordered is null 
	and orderId is null 
	and a.apstatus in ('p','w')
	and e.Investigator =IsNull(@vendor,'REFPRO')
	and IsNull(e.IsOnReport,0) = 1
	--and cg.GroupCode is null --TEMP: to exlude onshore caller group until ZipCrim is ready to accept "OAHCA" clients
	--and 1 = 0 -- TEMP: for production test to stop order submission
	--and e.APNO IN  (4239243, 7196509) -- TEMP: for testing purpose


	UPDATE E	  
	  SET dateordered = cast(replace(CURRENT_TIMESTAMP, datepart(year,CURRENT_TIMESTAMP),1900) as datetime) --SY (DD put SYs change in on 10/4/2017): updated to include time information
	  FROM dbo.empl  E 
	  INNER JOIN  #tmpOrders T ON E.EmplID = T.SectionKeyId

	select *
from (
              SELECT        
              ROW_NUMBER() over (partition by A.apno order by A.apno ) RowNumber ,
		      e.EmplID,
              case when e.IsIntl = 1 then 'IntlEmployment' else 'Employment' end as SectionType,              
              a.Addr_Street as Address_Street,  
              a.Middle as Middle,
              a.First as First,
              a.ApStatus as ApStatus,    
              a.APNO as Apno,            
              a.Last as Last,
              Alias = STUFF((SELECT ', '+ CAST((AA.First) as NVARCHAR(255))+' '+ CAST(ISNull((AA.Middle),'') as NVARCHAR(255))+' '+ CAST((AA.LAST) as NVARCHAR(255))             
							 FROM ApplAlias AA where AA.APNO=a.APNO FOR XML PATH('')),1,1,''),                                   
              case when IsNull('SJV','') = 'SJV' then CONVERT(varchar(10), a.DOB, 126) else CONVERT(varchar(10), a.DOB, 110) end as Date_Of_Birth,
              a.City as City,
              a.State as State,
              a.Phone as ApplicantPhone,
              c.Name as Client_Name,
              c.AffiliateId,
              IsNull(c.WebOrderParentCLNO, 0) as ParentId,
              c.CLNO as ChildId,
			   IsNull(c.OkToContact,0) as OkToContactClient,
              REPLACE(a.DeptCode,'Req ID:','') as ProcessLevel,
			  a.Investigator as Investigator,      
              a.SSN as Social_Security_Number,  
              a.generation as Generation,
              a.Zip as Zip,
              IsNull(e.IsIntl,0) as IsIntl,
              e.EmplId as ItemId,
              e.Salary_A as Salary,
              e.Position_A as Position,
              e.From_A as Employed_From_Date,
              e.To_A as Employed_To_Date, 
              e.Supervisor as Supervisor, 
              e.Employer as Employer,
              e.City as Employer_City,          
              e.RFL as Reason_For_Leaving,
              e.DNC as Do_Not_Contact,
              e.Phone as Employer_Phone, 
              e.State as Employer_State,
              IsNull(e.Location,'') as Employer_Address,
              e.OrderId as ItemOrderId,
              e.Priv_Notes as Comments,
              e.Investigator as Employment_Investigator,
              e.sectstat,
              IsNull(e.web_status, 0) as web_status,
			  (
				  CASE ISNULL(ccf.[Value],'True')
				  WHEN 'True' THEN 'False'
				  WHEN 'False' THEN 'True'
				  ELSE 'False'
				  END
			  ) as NoEmplPassThru,
			  o.AffiliateName,
			  o.CallerLocation as CallerLocation
     FROM dbo.Empl e 
       inner join #tmpOrders o WITH (NOLOCK) 
       on e.EmplID = o.SectionKeyId
       INNER JOIN dbo.appl a WITH (NOLOCK) 
       ON a.apno = e.apno
     -- inner JOIN ApplAlias AS AA(NOLOCK) ON AA.APNO = e.Apno
       INNER JOIN dbo.Client c ON a.CLNO = c.CLNO
	   LEFT JOIN 
	   (SELECT * FROM dbo.ClientConfiguration WHERE configurationKey = 'ApprovedEmplPassThroughCharges') ccf on c.CLNO=ccf.CLNO
) a
--where a.RowNumber = 1
	
Drop table #tmpOrders

END
