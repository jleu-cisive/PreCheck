

-- ==========================================================================================
-- Author:		Douglas DeGenaro
-- Create date: 1/20/2014
-- Description:	Gets only the summary fields
--Example
/* 
	
	dbo.PrecheckFramework_GetSummaryInfo 2465174
	2188027 
*/
--Modified: schapyala 02/12/14 to return status description and suppressing hidden/unused per section
-- ==========================================================================================
--[dbo].[PrecheckFramework_GetSummaryInfo] 3434366
CREATE PROCEDURE [dbo].[PrecheckFramework_GetSummaryInfo] 
	-- Add the parameters for the stored procedure here
	@apno int	
AS
--TEST--
--[dbo].[PrecheckFramework_GetSummaryInfo] 2464537
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @CLNO int
	DECLARE @clientName varchar(100)
	DECLARE @packageId smallint
	DECLARE @packageDesc varchar(100)
	DECLARE @cam varchar(8)

	DECLARE @DefSectionStatus varchar(50)
	SET @DefSectionStatus = 'Needs Review'

	SELECT @CLNO = a.CLNO FROM dbo.Appl a where apno = @apno;

	SELECT
		'Application' as SectionName,
		APNO as APNO,
		a.CLNO as CLNO,		
		First,
		Last,		
		DOB,
		IsNull(SSN,'') SSN,
		ApDate,
		Upper(ApStatus) as ApStatus,
		a.userid as cam,
		Investigator,
		PackageID,	
		a.Alias1_Last,
		a.Alias1_First,
		a.Alias1_Middle,	
		a.Alias1_Generation,
		a.Alias2_Last,
		a.Alias2_First,
		a.Alias2_Middle,	
		a.Alias2_Generation,
		a.Alias3_Last,
		a.Alias3_First,
		a.Alias3_Middle,	
		a.Alias3_Generation,
		a.Alias4_Last,
		a.Alias4_First,
		a.Alias4_Middle,	
		a.Alias4_Generation,	
		cast(a.Priv_Notes AS varchar(MAX)) as Priv_Notes				
	FROM 
		dbo.Appl a 
	where Apno = (@apno)

	---ApplAliases
	--SELECT 
	--	'ApplAlias' as SectionName,	
	--	First,
	--	Middle,
	--	Last,
	--	Generation
	--From 
	--	dbo.ApplAlias
	--Where
	--	apno = @apno


	Select 'ApplAlias' as SectionName,	
		A.First,
		A.Middle,
		A.Last,
		A.Generation from (
         SELECT  distinct 'ApplAlias' as SectionName,MIN(ApplAliasID) as SectionId, First,isnull(Middle,'') Middle,Last,isnull(Generation,'') Generation
		, cast(max(cast(IsPublicRecordQualified as int)) as bit) IsPublicRecordQualified, cast(max(cast(IsPrimaryName as int)) as bit) IsPrimaryName, MIN(CreatedDate) CreatedDate, MIN(CreatedBy) CreatedBy
		FROM dbo.ApplAlias 		
        where Apno = @apno and IsActive = 1 
        GROUP BY First,isnull(Middle,''),Last,isnull(Generation,'')
		)A  where A.IsPrimaryName = 0
		Order By A.IsPublicRecordQualified desc	
	

    -- Get Employment information
	SELECT 
			'Employment' as SectionName,
			--EmplID as SectionID,
			IsNull(Employer,'') as Employer,
			IsNull(Position_A,'') as Position,
			IsNull(From_A,'') as From_A,
			IsNull(To_A,'') as To_A,
			IsNull(From_V,'') as From_V,
			IsNull(To_V,'') as To_V,
			IsNull(Pub_Notes,'') as Pub_Notes,
			ISNULL([Description],@DefSectionStatus) [Status]
			--IsOnReport,
			--'Current' as RecordType				
	FROM 
		dbo.Empl E LEFT JOIN dbo.SectStat S on E.SectStat = Code
	WHERE 
		Apno = (@apno) AND IsNull(IsOnReport,0) = 1  AND IsNull(IsHidden,0) = 0

	--- Get Education info
	SELECT 
			'Education' as SectionName,
			--EducatID as SectionID,
			IsNull(School,'') as School,
			IsNull(Degree_A,'') as Degree_A,
			IsNull(From_A,'') as From_A,
			IsNull(To_A,'') as To_A,
			IsNull(Pub_Notes,'') as Pub_Notes,
			ISNULL([Description],@DefSectionStatus) [Status]
			--IsOnReport,
			--'Current' as RecordType		
	FROM 
		dbo.Educat E LEFT JOIN dbo.SectStat S on E.SectStat = Code 
	WHERE 
		Apno = (@apno) AND IsNull(IsOnReport,0) = 1  AND IsNull(IsHidden,0) = 0

	--License
	SELECT 
		'Licensing' as SectionName,
		--ProfLicID as SectionID,
		IsNull(Lic_Type,'') as Lic_Type,
		ISNULL([State],'') as [State],
		IsNull(Lic_No,'') as Lic_No,
		ISNULL([Year],'') as [Year],
		CASE WHEN 
			Expire IS not NULL 
		THEN 
			IsNull(Convert(varchar,Expire,101),'')
		ELSE
			 '' end as Expire,
		IsNull(Pub_Notes,'') as Pub_Notes,
		ISNULL([Description],@DefSectionStatus) [Status]
		--IsOnReport,
		--'Current' as RecordType					
	FROM 
		dbo.ProfLic E LEFT JOIN dbo.SectStat S on E.SectStat = Code
	where 
		Apno = (@apno) AND IsNull(IsOnReport,0) = 1  AND IsNull(IsHidden,0) = 0
	
	--ProfLic
	SELECT
		'PersRef' as SectionName,
		--PersRefID as SectionID,
		IsNull(Name,'') as Name,
		IsNull(Phone,'') as Phone,
		IsNull(Email,'') as Email,
		IsNull(Rel_V,'') as Rel_V,
		IsNull(JobTitle,'') as JobTitle,
		IsNull(Pub_Notes,'') as Pub_Notes,
		ISNULL([Description],@DefSectionStatus) [Status]
		--IsOnReport,
		--'Current' as RecordType			
	FROM
		dbo.PersRef  E LEFT JOIN dbo.SectStat S on E.SectStat = Code
	WHERE 
		Apno = (@apno) AND IsNull(IsOnReport,0) = 1  AND IsNull(IsHidden,0) = 0
	
	--Get Requirements
	   SELECT 
			'ClientRequirements' as SectionName,			
			Social as PositiveID, 
			[Medicaid/Medicare] as SanctionCheck, 
			MVRService,  
			MVR, 
			PersonalRefNotes,       
			CN.CreditNotes,
			A.Affiliate,    
			Req.ProfRef, 
			Req.DOT, 
			Req.SpecialReg, 
			Req.Civil, 
			Req.Federal, 
			Req.Statewide    
		FROM   
			dbo.Client  C left join dbo.refCreditNotes CN on C.CreditNotesID = CN.CreditNotesID             
			LEFT JOIN dbo.refAffiliate A on C.AffiliateID = A.AffiliateID    
			LEFT JOIN dbo.refRequirementText Req on C.CLNO = Req.CLNO      
		WHERE 
			(C.CLNO = @CLNO)    

	
	--MVR/SanctionCheck/Credit
	
	SELECT 
		'MVR' as SectionName,
		[Description] [Status]
	FROM
		dbo.DL  E LEFT JOIN dbo.SectStat S on E.SectStat = Code
	WHERE
		Apno = (@apno)  AND IsNull(IsHidden,0) = 0
	
	SELECT 
		'SanctionCheck' as SectionName,
		[Description] [Status]
	FROM
		dbo.MedInteg  E LEFT JOIN dbo.SectStat S on E.SectStat = Code
	WHERE
		Apno = (@apno)  AND IsNull(IsHidden,0) = 0
	
	SELECT 
		'Credit' as SectionName,
		[Description] [Status]
	FROM
		dbo.Credit  E LEFT JOIN dbo.SectStat S on E.SectStat = Code
	WHERE
		Apno = (@apno) AND RepType='C'  AND IsNull(IsHidden,0) = 0
	
	SELECT 
		'PositiveID' as SectionName,
		[Description] [Status] 
	FROM
		dbo.Credit  E LEFT JOIN dbo.SectStat S on E.SectStat = Code
	WHERE
		Apno = (@apno) AND RepType='S'  AND IsNull(IsHidden,0) = 0
			
	--Public records
	SELECT
		'Crim' as SectionName,
		--CrimID as SectionID,
		IsNull(County,'') as County,
		IsNull(Disposition,'') as Disposition,
		CASE WHEN 
			C.Disp_Date IS not NULL 
		THEN 
			IsNull(Convert(varchar,Disp_Date,101),'')
		ELSE
			 '' end as Disp_Date,
		CASE WHEN 
			c.AdmittedRecord = 1 then 'True' 
		ELSE 
			'False' 
		END SelfDisclosed,
		IsNull(Pub_Notes,'') as Pub_Notes,
		IsNull(CRIM_SpecialInstr,'') as CRIM_SpecialInstr,
		IsNull(crimdescription,@DefSectionStatus) as [Clear] 
	FROM
		dbo.Crim  C LEFT JOIN dbo.CrimSectStat S on C.[Clear] = crimsect
		
	where 
		c.Apno = (@apno)  AND IsNull(IsHidden,0) = 0
	Order BY C.County
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED	
	SET NOCOUNT OFF;

END


