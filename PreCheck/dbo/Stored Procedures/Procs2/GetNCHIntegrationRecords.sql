CREATE PROCEDURE  [dbo].[GetNCHIntegrationRecords] 
AS
BEGIN
	DECLARE @ErrorCode int

	BEGIN TRANSACTION
	SET @ErrorCode=@@Error

	
DECLARE @NCHIntegration TABLE (APNO int, ApStatus char(1), SSN varchar(11), Priv_Notes varchar(max), 
									Pub_Notes varchar(max), [First] varchar(50), [Last] varchar(50), EducatID int, EducatVerifyID varchar(20), 
									school varchar(100), 
									degree_A varchar(50),
									studies_A varchar(50),
									degree_V varchar(50),
									studies_V varchar(50),
									[State_School] varchar(2), City_School varchar(50), ZipCode_School char(5), 
									[State_Appl] varchar(2), City_Appl varchar(50), ZipCode_Appl char(5),  AddressLine1_Appl char(100), 
									From_A varchar(12), IsFrom_AYear bit, From_V varchar(12), To_A varchar(12), IsTo_AYear bit,
									To_V varchar(12), 
									SectStat char(1), 
									ver_by varchar(50), web_status int, name varchar(100), CodeCount int, NoPassThroughCharges  bit, ApprovedPassThroughCharges bit, EducatAccreditationRequired bit, VerifyType varchar(20),
									IsDegreeMatched bit, IsStudyMatched bit, SourceVerifyType varchar(100), SourceVerifyName varchar(100), Contact_Title varchar(50), Investigator varchar(30),
									AffiliateName nvarchar(50),
									ClientName varchar(100),
									OkToContact bit,
									CallerLocation varchar(1000),
									IsInternationalEquivalency bit,
									ApplicantEmail varchar(155),
									ClientEmail VARCHAR(155),
									CcClient VARCHAR(20),
									MaxAttempt VARCHAR(20),
									[Priority] VARCHAR(20),
									ClientType VARCHAR(20),
									RowNum INT
								)

	INSERT INTO @NCHIntegration(APNO, ApStatus, SSN, Priv_Notes, 
								Pub_Notes, [First], [Last], EducatID, EducatVerifyID, 
								school, 
								degree_A,
								studies_A,
								degree_V,
								studies_V,
								State_School,City_School,ZipCode_School,
								State_Appl,City_Appl,ZipCode_Appl,AddressLine1_Appl,
								From_A, IsFrom_AYear, From_V, To_A, IsTo_AYear,
								To_V, 
								SectStat,
								ver_by, web_status, name, CodeCount, NoPassThroughCharges, ApprovedPassThroughCharges, EducatAccreditationRequired, VerifyType, IsDegreeMatched, IsStudyMatched, SourceVerifyType, SourceVerifyName, 
								Contact_Title, Investigator,
								AffiliateName,
								ClientName,
								OkToContact,
								CallerLocation,
								IsInternationalEquivalency,
								ApplicantEmail,
								ClientEmail,
								CcClient,
								MaxAttempt,
								[Priority],
								ClientType,
								RowNum
								)

SELECT TOP 200 a.APNO, a.ApStatus, a.SSN, '' as Priv_Notes, '' as Pub_Notes, a.First, a.Last, e.EducatID, 0 as EducatVerifyID, 
			school, 
			degree_A,
			studies_A,
			degree_V,
			studies_V,
			e.state as State_School, e.city AS City_School, e.zipcode AS ZipCode_School, 
			a.state as State_Appl, a.City AS City_Appl, a.Zip AS ZipCode_Appl,a.Addr_Street,
			ISNULL(e.From_A,'') as From_A,   
			0, e.From_V, 
			ISNULL(e.To_A,'') as To_A,  
			0,
			e.To_V,
			e.SectStat, 
			'NCHWinService' as ver_by, e.web_status, c.name, 0, IsNull(g.NoPassThroughCharges, 0), IsNull(g.ApprovedPassThroughCharges, 1), IsNull(g.EducatAccreditationRequired, 0), 'Education', 0, 0, 0, 0, 'NCHWinService', 
			case when rtrim(ltrim(e.Investigator)) = '' or rtrim(ltrim(e.Investigator)) = '0' then 'N/A' else e.investigator end as investigator,
			case when r.AffiliateID in (213,214,220,221,223,225,226,258,271,279,283,284,285,287,288,289,295,306)  then ''
			else r.Affiliate end AS AffiliateName,
			c.Name as ClientName,
			IsNull(c.OkToContact,0),
			case
				WHEN cg.GroupCode = 6 THEN 'Onshore' 
				WHEN  cg.GroupCode = 7 THEN 'Offshore' 
				ELSE 'All'  
			 end AS CallerLocation,
			CASE
				WHEN LTRIM(RTRIM(e.School)) LIKE '%Equivalency%' then 1
				ELSE 0
			END AS 	IsInternationalEquivalency,
			ISNULL(a.Email,'') as ApplicantEmail,
			ISNULL(c.Email,'') AS ClientEmail,
			g.CC_Client_On_Applicant_Contact as CcClient,
			IsNull(g.Max_Attempt, '3') as MaxAttempt,
			g.Priority as [Priority],
			CASE WHEN g.ProofClient = 'True' THEN 'Proof' ELSE '' END AS ClientType,
			ROW_NUMBER() OVER (Partition by e.APNO ORDER BY e.CreatedDate)
	FROM dbo.Educat e with (nolock) 
	INNER JOIN dbo.Appl a with (nolock) ON e.apno = a.apno 
	INNER JOIN dbo.Client c with (nolock) ON a.clno = c.clno
	INNER JOIN dbo.refAffiliate r on r.AffiliateID = c.AffiliateId
	LEFT JOIN dbo.ClientGroup cg on cg.clno = c.clno and cg.groupcode in (6,7) and cg.IsActive = 1
	LEFT JOIN (select max(case when ConfigurationKey = 'NoEducatPassThroughCharges'then value end) 'NoPassThroughCharges',
					  max(case when ConfigurationKey = 'ApprovedEducatPassThroughCharges' then value end) 'ApprovedPassThroughCharges',
					  max(case when ConfigurationKey = 'Educat_Accredition_Required' then value end) 'EducatAccreditationRequired',
					  max(case when ConfigurationKey = 'CC_Client_On_Applicant_Contact' then value end) 'CC_Client_On_Applicant_Contact',
					  max(case when ConfigurationKey = 'Max_Attempt' then value end) 'Max_Attempt',
					  max(case when ConfigurationKey = 'Priority' then value end) 'Priority',
					  max(case when ConfigurationKey = 'ProofClient' then value end) 'ProofClient',
					 clno
				  FROM( select clno,
							  ConfigurationKey, 
							  Value
						from clientconfiguration where (ConfigurationKey ='ApprovedEducatPassThroughCharges' or ConfigurationKey ='NoEducatPassThroughCharges' or ConfigurationKey ='Educat_Accredition_Required'
						or ConfigurationKey = 'CC_Client_On_Applicant_Contact' or ConfigurationKey = 'Max_Attempt' or ConfigurationKey = 'Priority' or ConfigurationKey = 'ProofClient')
						)a  
					group by clno) g  ON g.CLNO = c.clno
			WHERE 
			e.SectStat = '9'
			and IsNull(e.web_status,0) = 0 
			and dateordered is null 
			and orderId is null 
			and a.apstatus in ('p','w')
			and (e.Inuse is null or e.Inuse = '') 			
			and (e.investigator is null OR e.Investigator = 'NCH')
			and IsNull(e.IsOnReport,0) = 1
			and LTRIM(RTRIM(e.School)) NOT LIKE '%Equivalency%' --TEMP: DO NOT ROUTE TO ZIPCRIM UNTIL DIST GROUP IS SETUP
			and c.IsInactive = 0
			--and cg.GroupCode is null --TEMP: to exlude onshore caller group
			--and e.apno in (6802040) --TO SEND ORDERS UNDER A SPECIFIC APNO
			--and 1 = 0 -- TEMP: for production test to stop order submission
	
		DELETE n
		FROM @NCHIntegration n
		WHERE n.RowNum > 1

		
		DELETE n
		FROM @NCHIntegration n
		WHERE n.APNO NOT IN (SELECT TOP 20 n.APNO
							FROM @NCHIntegration n
							)


		
	UPDATE Educat
	        SET Investigator = 'NCH', dateordered = cast(replace(CURRENT_TIMESTAMP, datepart(year,CURRENT_TIMESTAMP),1900) as datetime)
	            WHERE EducatID IN( select Educatid from @NCHIntegration)
         


		SELECT distinct n.APNO, n.ApStatus, n.SSN, n.Priv_Notes, 
				n.Pub_Notes, n.[First], n.[Last], n.EducatID, n.EducatVerifyID, 
				n.school, 
				n.degree_A,
				n.studies_A,
				n.degree_V,
				n.studies_V,
				n.State_School,n.City_School,n.ZipCode_School,
				n.State_Appl,n.City_Appl,n.ZipCode_Appl, n.AddressLine1_Appl,
				n.From_A, n.IsFrom_AYear, n.From_V, n.To_A, n.IsTo_AYear,
				n.To_V, 
				n.SectStat,
				n.ver_by, n.web_status, n.name, n.CodeCount, n.NoPassThroughCharges, n.ApprovedPassThroughCharges, n.VerifyType, n.IsDegreeMatched, n.IsStudyMatched, 
			   t.Description as SourceVerifyType, 
			   n.SourceVerifyName,
			   n.Contact_Title, n.Investigator, n.EducatAccreditationRequired,
			   nc.FeesRetailandCorporate,
			   case when i.SubKeyChar is NULL or i.SubKeyChar = '' then cast(0 as bit) else cast(1 as bit) end as Isbilled,
			   n.AffiliateName,
			   n.ClientName,
			   n.OkToContact,
			   n.CallerLocation,
			   n.IsInternationalEquivalency,
			   n.ApplicantEmail,
			   n.ClientEmail,
			   n.CcClient,
			   n.MaxAttempt,
			   n.[Priority],
		       n.ClientType

	    FROM @NCHIntegration n left join invdetail (nolock) i on n.apno = i.apno and cast(n.EducatVerifyID as varchar(10)) = i.subkeychar 
		left join refVerificationType t on
		t.refVerificationType = n.SourceVerifyType 
		left join [NCHListwPrice] nc on nc.SchoolCode = n.EducatVerifyID 
		
		       

	If (@ErrorCode<>0)
	  Begin
	  RollBack Transaction
	  Return (-@ErrorCode)
	  End
	Else
	  Commit Transaction

END

