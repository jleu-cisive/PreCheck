--[Verification_GetPendingEmployments] 'AALexand'
--[dbo].[Verification_GetPendingEmployments_04252016] 'REFPRO'

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


CREATE procedure [dbo].[Verification_GetPendingEmployments_04252016] 
(@vendor varchar(30) = null)

AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #tmpVerification(
		[SectionType] [varchar](14) NOT NULL,
		[Address_Street] [varchar](100) NULL,
		[Middle] [varchar](20) NULL,
		[First] [varchar](20) NOT NULL,
		[ApStatus] [char](1) NOT NULL,
		[Apno] [int] NOT NULL,
		[Last] [varchar](20) NOT NULL,
		[Date_Of_Birth] [varchar](10) NULL,
		[City] [varchar](50) NULL,
		[State] [varchar](2) NULL,
		[Investigator] [varchar](8) NULL,
		[Alias1_First] [varchar](20) NULL,
		[Alias1_Middle] [varchar](20) NULL,
		[Alias1_Last] [varchar](20) NULL,
		[Alias2_First] [varchar](20) NULL,
		[Alias2_Middle] [varchar](20) NULL,
		[Alias2_Last] [varchar](20) NULL,
		[Alias3_First] [varchar](20) NULL,
		[Alias3_Middle] [varchar](20) NULL,
		[Alias3_Last] [varchar](20) NULL,
		[Alias4_First] [varchar](20) NULL,
		[Alias4_Middle] [varchar](20) NULL,
		[Alias4_Last] [varchar](20) NULL,
		[Social_Security_Number] [varchar](11) NULL,
		[Generation] [varchar](3) NULL,
		[Zip] [varchar](5) NULL,
		[ItemId] [int] NOT NULL,
		[Salary] [varchar](50) NULL,
		[Position] [varchar](50) NULL,
		[Employed_From_Date] [varchar](30) NULL,
		[Employed_To_Date] [varchar](30) NULL,
		[Supervisor] [varchar](25) NULL,
		[Employer] [varchar](30) NOT NULL,
		[Employer_City] [varchar](50) NULL,
		[Reason_For_Leaving] [varchar](50) NULL,
		[Do_Not_Contact] [bit] NOT NULL,
		[Employer_Phone] [varchar](20) NULL,
		[Employer_State] [char](2) NULL,
		[ItemOrderId] [varchar](20) NULL,
		[Comments] [text] NULL,
		[Employment_Investigator] [varchar](8) NULL,
		[sectstat] [char](1) NOT NULL,
		[web_status] [int] NULL
	) ;

	CREATE CLUSTERED INDEX IX_tmpVerification_01 ON #tmpVerification([ItemId]);

	INSERT INTO #tmpVerification
	SELECT 	
		case when e.IsIntl = 1 then 'IntlEmployment' else 'Employment' end as SectionType,	
		a.Addr_Street as Address_Street,	
		a.Middle as Middle,
		a.First as First,
		a.ApStatus as ApStatus,	
		a.APNO as Apno,		
		a.Last as Last,			
		CONVERT(varchar(10), a.DOB, 101)as Date_Of_Birth,
		a.City as City,
		a.State as State,
		a.Investigator as Investigator,
		--null as Investigator,
		a.Alias1_First as Alias1_First,
		a.Alias1_Middle as Alias1_Middle,
		a.Alias1_Last as Alias1_Last,
		a.Alias2_First as Alias2_First,
		a.Alias2_Middle as Alias2_Middle,
		a.Alias2_Last as Alias2_Last,
		a.Alias3_First as Alias3_First,
		a.Alias3_Middle as Alias3_Middle,
		a.Alias3_Last as Alias3_Last,
		a.Alias4_First as Alias4_First,
		a.Alias4_Middle as Alias4_Middle,
		a.Alias4_Last as Alias4_Last,
		a.SSN as Social_Security_Number,	
		a.generation as Generation,
		a.Zip as Zip,
		--IsNull(e.IsIntl,0) as IsIntl,
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
		e.OrderId as ItemOrderId,
		e.Priv_Notes as Comments,
		e.Investigator as Employment_Investigator,e.sectstat,e.web_status 
		FROM dbo.empl e  WITH (NOLOCK) INNER JOIN dbo.appl a WITH (NOLOCK) 
		ON a.apno = e.apno
	WHERE e.sectstat in ('9') and web_status = 0 and dateordered is null and orderId is null and a.apstatus in ('p','w')
	and e.Investigator = @vendor
	and IsNull(a.SSN,'') <> ''

	  IF @@rowcount > 0 
		BEGIN
			  --UPDATE E 
			  --SET   dateordered = '1/1/1900'  
			  --FROM dbo.empl  E INNER JOIN  #tmpVerification T
			  --ON E.EmplID = T.ItemId
	    
			  ---- added for logging    
			  --INSERT into dbo.ReferenceProLog(sectionId,apno,Data,LogDate)  
			  --SELECT   
			  -- ItemId,  
			  -- Apno,  
			  -- '[Selected] Section:Employment' + '; sectstat:' + cast(sectstat as varchar(10)) + '; webstatus:' + cast(web_status as varchar(20)) + '; dateOrdered:1/1/1900' + '; orderid:' + IsNull(ItemOrderId,'null') + '; apstatus:' + ApStatus + '; investigator:' + Employment_Investigator + '; SSN:' + IsNull(Social_Security_Number,'')  + '; Vendor:' + IsNull(@vendor,'') 
			  -- ,CURRENT_TIMESTAMP  
			  --FROM #tmpVerification            
	  
			 SELECT * FROM #tmpVerification ORDER BY itemid DESC
		END

		 Drop table #tmpVerification;

 	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT Off;

END;
