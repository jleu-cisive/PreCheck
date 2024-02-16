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
--[dbo].[Verification_GetPendingEmployments] 'SJV'

CREATE procedure [dbo].[Verification_GetPendingEmployments_Test] 
(@vendor varchar(30) = null)

AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	CREATE TABLE #tmpOrders(	
	SectionKeyId int	
	)

	CREATE CLUSTERED INDEX IX_tmpOrders_01 ON #tmpOrders(SectionKeyId);

	
	insert into #tmpOrders
	select e.EmplID
	FROM dbo.empl e  WITH (NOLOCK) INNER JOIN dbo.appl a WITH (NOLOCK) 
		ON a.apno = e.apno
	WHERE e.sectstat in ('9') and IsNull(web_status,0) = 0 
	and dateordered is null 
	and orderId is null and a.apstatus in ('p','w')
	and e.Investigator = IsNull(@vendor,'REFPRO')
	and IsNull(e.IsOnReport,0) = 1
	--and e.EmplId in (4338058)

	UPDATE E 
	  SET   dateordered = cAST((CAST(MONTH(CURRENT_TIMESTAMP) AS VARCHAR) + '/' + CAST(DAY(CURRENT_TIMESTAMP) AS VARCHAR) + '/1900') AS DATE)--'1/1/1900'  
	  FROM dbo.empl  E INNER JOIN  #tmpOrders T
	  ON E.EmplID = T.SectionKeyId

	SELECT 	
		case when e.IsIntl = 1 then 'IntlEmployment' else 'Employment' end as SectionType,			
		a.Addr_Street as Address_Street,	
		a.Middle as Middle,
		a.First as First,
		a.ApStatus as ApStatus,	
		a.APNO as Apno,		
		a.Last as Last,			
		case when IsNull(@Vendor,'') = 'SJV' then CONVERT(varchar(10), a.DOB, 126) else CONVERT(varchar(10), a.DOB, 110) end as Date_Of_Birth,
		a.City as City,
		a.State as State,
		a.Phone as ApplicantPhone,
		--a.Country as Country,
		a.Investigator as Investigator,
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
		e.web_status  
	FROM dbo.Empl e 
	inner join #tmpOrders o WITH (NOLOCK) 
	on e.EmplID = o.SectionKeyId
	INNER JOIN dbo.appl a WITH (NOLOCK) 
	ON a.apno = e.apno	
	ORDER BY o.SectionKeyId DESC
		
	
	Drop table #tmpOrders



END
