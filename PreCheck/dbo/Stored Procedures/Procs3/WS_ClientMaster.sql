--sp_helptext 'WS_ClientMaster'  
--WS_ClientMaster 11140,@IncludeClientRequirements = 1
  

    

-- =============================================    

-- Author:  Santosh Chapyala    

-- Create date: 03/21/2012    

-- Description: This SP returns all the client related data in one go.    

--    This is primarily consumed by the Client Master web Service     

-- =============================================    

 

-- =============================================    

-- Updated By:  Douglas DeGenaro    

-- Updated date: 08/24/2012    

-- Description: Made a change the client contacts, to show TBD/NA at the top of the list, which they can select

-- and tells the investigator that there wasnt a client contact at the time of app creation.

-- =============================================   

 

-- =============================================    

-- Updated By:  Dongmei He    

-- Updated date: 08/29/2012    

-- Description: Changed inner join to left join tables like dbo.refCreditNotes,dbo.refAffiliate and dbo.refRequirementText.

-- =============================================    

-- =============================================    


-- Updated By:  Douglas DeGenaro  

-- Where: Line 196 

-- Updated date: 11/02/2012    

-- Description: Changed sorting on client notes to sort by the note itself alphabetically

-- =============================================   
 
 --[dbo].[WS_ClientMaster] 12490,@IncludeClientRequirements = 1
CREATE PROCEDURE [dbo].[WS_ClientMaster]    

 -- Add the parameters for the stored procedure here    

 @CLNO Int,    

 @IncludeClientContacts Bit = 0,    

 @IncludeClientRequirements Bit = 0,    

 @IncludeClientNotes Bit = 0,    

 @IncludeClientPackageDetails Bit = 0,    

 @IncludeClientConfigurations Bit = 0    

AS    

BEGIN    

 -- SET NOCOUNT ON added to prevent extra result sets from    

 -- interfering with SELECT statements.    

 SET NOCOUNT ON;    

 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED     

    

 SELECT  C.Name, Addr1, Addr2, City, [State],Zip,  C.CAM, U.EmailAddress CAM_Email,Investigator1, Investigator2,     

   rc.ClientType, HighProfile, OKtoContact      

 FROM dbo.Client  C left join dbo.refClientType rc on C.ClientTypeID = rc.ClientTypeID    

        left join dbo.users U on C.CAM = U.UserID    

 WHERE (C.CLNO = @CLNO)    

    

 IF @IncludeClientContacts = 1    

  --SELECT FirstName,LastName,Email,Phone From DBO.ClientContacts Where CLNO = @CLNO and IsActive = 1 order by LastName,FirstName 

  SELECT FirstName,LastName,Email,Phone,Title,Ext,UserName,UserPassword,ContactType FROM
	
      (SELECT 2 as rank,RTRIM(LTRIM(FirstName)) as FirstName,RTRIM(LTRIM(LastName)) as LastName,Email,Phone,Title,Ext,UserName,UserPassword,ContactType From DBO.ClientContacts 

            Where CLNO = @clno and IsActive = 1 and IsNull(FirstName,'') <> '' and IsNull(LastName,'') <> ''

                  Union
	  --Change to
	  --SELECT 1 as rank,'To Be Determined' as FirstName,'' as LastName,'' as Email ,'' as Phone,'' as Title,'' as Ext,'' as UserName,'' as UserPassword,'' as ContactType) dt	
      SELECT 1 as rank,'Determined' as FirstName,'To Be' as LastName,'' as Email ,'' as Phone,'' as Title,'' as Ext,'' as UserName,'' as UserPassword,'' as ContactType) dt

      order by rank,LastName,FirstName 

 ELSE    

  SELECT  FirstName,LastName,Email,Phone,Title,Ext,UserName,UserPassword,ContactType From DBO.ClientContacts Where 1 = 0 order by LastName,FirstName  

      

    

 IF @IncludeClientRequirements = 1    

  BEGIN    

   SELECT 'ClientRequirements' Node,C.CLNO, Social PositiveID, [Medicaid/Medicare] SanctionCheck, MVRService,  MVR, PersonalRefNotes,       

       CN.CreditNotes, A.Affiliate,    

       Req.ProfRef, Req.DOT, S.Description as SpecialReg, CV.Description as Civil, F.Description as Federal, --COALESCE(Req.Statewide,SW.Description) as Statewide
	   SW.Description as Statewide

   FROM   dbo.Client  C left join dbo.refCreditNotes CN on C.CreditNotesID = CN.CreditNotesID             

         left join dbo.refAffiliate A on C.AffiliateID = A.AffiliateID    

         left join dbo.refRequirementText Req on C.CLNO = Req.CLNO      

		 left join [dbo].[refStatewide] SW on Req.StatewideID = SW.StateWideID

		 LEFT JOIN dbo.refStatewide F WITH(NOLOCK) ON F.StateWideID = Req.FederalID
	LEFT JOIN dbo.refStatewide CV WITH(NOLOCK) ON CV.StateWideID = Req.CivilID 
	LEFT JOIN dbo.refStatewide S WITH(NOLOCK) ON S.StateWideID = Req.SpecialRegID

   WHERE (C.CLNO = @CLNO)  

         

   SELECT  RecordType, SpecialNote, NumOfRecord, TimeSpan, LevelNum, IsSeeNotes, IsMostRecent, IsOrdered, IsCalled,     

    IsHighestCompleted, IsHighSchool, IsCollege, IsHCA     

    FROM dbo.refRequirement     

    WHERE (CLNO = @CLNO)                

  END    

 ELSE    

  BEGIN    

   SELECT 'ClientRequirements' Node,C.CLNO, Social PositiveID, [Medicaid/Medicare] SanctionCheck, MVRService,  MVR, PersonalRefNotes,       

       '' CreditNotes, '' Affiliate,    

       '' ProfRef, '' DOT, '' SpecialReg, '' Civil, '' Federal, '' Statewide    

   FROM   dbo.Client  C      

   WHERE (1=0)      

      

   SELECT  RecordType, SpecialNote, NumOfRecord, TimeSpan, LevelNum, IsSeeNotes, IsMostRecent, IsOrdered, IsCalled,     

   IsHighestCompleted,    

    IsHighSchool, IsCollege, IsHCA FROM dbo.refRequirement     

    WHERE (1 = 0)     

  END    

      

 IF @IncludeClientNotes = 1     


 --   --SELECT CLNO, NoteID, NoteType, NoteBy, NoteDate, NoteText FROM dbo.ClientNotes WHERE (CLNO = @CLNO) order by NoteDate desc  
	--SELECT CLNO, NoteID, NoteType, NoteBy, NoteDate, NoteText FROM dbo.ClientNotes WHERE (CLNO = @CLNO) order by LTRIM(cast(NoteText as varchar)) ASC
 
	  SELECT CLNO, NoteID, NoteType, NoteBy, NoteDate, NoteText 
	  FROM
	  (
		  SELECT CLNO, NoteID, 
		  --NoteType,--santosh included SI on 11/19/19
		  case when (NoteType in ('','CS','SI') OR NoteType IS NULL) THEN 'All' ELSE NoteType END NoteType, --modified by santosh/Doug to include CS, NULL and empty types into ALL client notes - 06/24/2013
		   NoteBy, NoteDate, NoteText FROM dbo.ClientNotes WHERE (CLNO = @CLNO)  --order by LTRIM(cast(NoteText as varchar)) ASC
		  UNION ALL
		  SELECT 0 CLNO,NoteItID NoteID,'NoteIt' NoteType, UserID NoteBy,CreateDate NoteDate,Note NoteText From dbo.NoteIt
	  ) QRY order by NoteType, LTRIM(cast(NoteText as varchar)) ASC

 ELSE    

  SELECT CLNO, NoteID,NoteType, NoteBy, NoteDate, NoteText FROM dbo.ClientNotes WHERE (1 = 0)     

      

    

 IF @IncludeClientPackageDetails = 1    

  BEGIN    

   Create table #tblPackages    

   (    

    PackageID Int,    

    PackageDesc varchar(200),    

    Rate numeric    

   )    

    

   Insert into #tblPackages     

   Exec [dbo].[GetClientPackageLevel] @CLNO    

    

   Select  PackageID,PackageDesc    

   , Max(CriminalCount) CriminalCount, Max(EmploymentCount) EmploymentCount,Max(EducationCount) EducationCount,Max(LicenseCount) LicenseCount     

   , Max(PersonalRefCount) PersonalRefCount, Max(MVRCount) MVRCount,Max(CreditCount) CreditCount,Max(CivilCount) CivilCount, Max(SocialSearch) SocialSearch    

   From (Select  P.PackageID,PackageDesc,    

     (Case when ServiceName = 'Criminal' then includedCount else 0 end) CriminalCount,    

     (Case when ServiceName = 'Employment' then includedCount else 0 end) EmploymentCount,    

     (Case when ServiceName = 'Education' then includedCount else 0 end) EducationCount,    

     (Case when ServiceName = 'ProfLicense' then includedCount else 0 end) LicenseCount,    

     (Case when ServiceName = 'PersonalRef' then includedCount else 0 end) PersonalRefCount,    

     (Case when ServiceName = 'MVR' then includedCount else 0 end) MVRCount,    

     (Case when ServiceName = 'Credit' then includedCount else 0 end) CreditCount,    

     (Case when ServiceName = 'Civil' then includedCount else 0 end) CivilCount,    

     (Case when ServiceName = 'Social Search' then 1 else 0 end) SocialSearch    

     From #tblPackages P  inner join  packageservice aa  on P.PackageID = aa.PackageID    

           inner join  defaultrates bb    on (aa.serviceid = bb.serviceid)     

     --Where includedcount>0
	 ) Qry    

   Group by PackageID,PackageDesc           

    

   DROP Table #tblPackages    

   END    

  ELSE    

  Select  PackageID,PackageDesc    

  , 0 CriminalCount, 0 EmploymentCount,0 EducationCount,0 LicenseCount     

  , 0 PersonalRefCount, 0 MVRCount,0 CreditCount,0 CivilCount, 0 SocialSearch    

  From PackageMain    

  Where 1 = 0    

    

 IF @IncludeClientConfigurations = 1    

 BEGIN    

  SELECT ConfigurationKey, Value     

  FROM   dbo.ClientConfiguration    

  WHERE  (CLNO = @CLNO or ApplyToEveryone = 1) and  ConfigurationKey <> 'DrugTestNotificationCustomText'  
       

  SELECT LockPackagePricing, NoPackageNoBill FROM dbo.ClientConfig_Billing where CLNO=@CLNO    

  END    

 ELSE    

 BEGIN    

  SELECT ConfigurationKey, Value     

  FROM   dbo.ClientConfiguration    

  WHERE  (1 = 0)     
        

  SELECT LockPackagePricing, NoPackageNoBill FROM dbo.ClientConfig_Billing WHERE(1=0)     

 END    

     

 SET NOCOUNT OFF     

END