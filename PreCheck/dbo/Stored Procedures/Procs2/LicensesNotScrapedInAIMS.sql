-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE LicensesNotScrapedInAIMS
	  --- Start date for filtering DataXtract_Logging.DateLogResponse
                     @DateLogResponseStart datetime = '8/1/2018',
                     --- End date for filtering DataXtract_Logging.DateLogResponse
                     @DateLogResponseEnd datetime = '8/18/2018',
                     --- value to be filtered on Section fields with a like operator
                     @Section varchar(20) = 'SBM_Not_Found_4' 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare  -- Variable for processing ..
                     @DataXtract_LoggingId int,
                     @xmlDoc VarChar(max),
                     @xmlHandle INT
					declare @counters int = 0

					 -- Select                    
      --                     *
      --               from 
      --                     DataXtract_Logging WIth(NOLOCK)
      --               where
      --               -- SectionKeyId like '%TX-RN%' and 
      --               (DateLogResponse between @DateLogResponseStart and @DateLogResponseEnd) 
                    
      --               and Section like	@Section 
      --               and (Response is not null and Response <> 'NULL')
      --               order by DataXtract_LoggingId --desc

					 --select  @DateLogResponseStart,    @DateLogResponseEnd ,   @Section
--CREATE TABLE #TABLE1  ( LICENSEID INT )

              -- Main selection cursor for retrieving log data..
              Declare crLogs Cursor Fast_Forward for
                     Select                   
                           DataXtract_LoggingId --,
                           --REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([Response],'Copyright Â  1997-2018','a'),' – ',''),'’',''),'"',' '),'©',' ') Response
                     from 
                           DataXtract_Logging WIth(NOLOCK)
						  
                     where
                     (DateLogResponse between @DateLogResponseStart and @DateLogResponseEnd) 
                    
                     and Section like 	@Section 
                     and (Response is not null and Response <> 'NULL')
                     order by DataXtract_LoggingId --desc

              
              Open crLogs
			 
              fetch next from CrLogs into @DataXtract_LoggingId --, @xmlDoc
              while @@FETCH_STATUS = 0
              Begin
			   set @counters = @counters +1

			   SELECT @xmlDoc=REPLACE(REPLACE([Request],' – ',' '),'’',' ')
			   --REPLACE(REPLACE(REPLACE(REPLACE(Response,' – ',''),'’',''),'"',' '),'©',' ')--REPLACE([Response],'©',' ')
					FROM         DataXtract_Logging 
					WHERE DataXtract_Loggingid  = 2500688
			  --select @DataXtract_LoggingId, @xmlDoc
                     -- Do we need to check for null values?
                     -- Do we need a transaction? Error handling? 
                     EXEC sp_xml_preparedocument @xmlHandle OUTPUT, @xmlDoc
                    INSERT INTO dbo.TCHAppno ( Apno)
					 SELECT 
                           *  
                     FROM OPENXML (@xmlHandle, '//Table1', 2) WITH
                           (
                                  Licenseid INT 'Licenseid'
                                  

                           )  --where licenseid = 2761563
                    -- order by ProvidedFirst

                     EXEC sp_xml_removedocument @xmlHandle
                     select distinct Licenseid from #TABLE1
					 select @counters
                     fetch next from CrLogs into @DataXtract_LoggingId
              End
              Close CrLogs

              deallocate CrLogs

			select distinct l.Licenseid,c.CLNO,c.Name, CAST(e.FacilityName as Char(100)) as [Facility Name], First, Last, EmployeeNumber, [JobCode],  [JobTitle],

 lt.ItemValue as   [Precheck Type],L.type 'Client Type',l.status, l.number [License #],l.issuingstate State,l.IssuingAuthority Authority,CurrentRestrictions,AnyRestrictions,  

  CONVERT(date,l.ExpiresDate,101) as [Expiration Date],
( CASE WHEN l.CredentialingStatus = 4
               THEN LTRIM (ISNULL(REPLACE(REPLACE(REPLACE(RefCredStat.Status, Char(10),''),Char(13),''),',',''),'')) + ' ('
                    + CONVERT(VARCHAR, l.ReviewDate, 101) + ')'
               WHEN l.CredentialingStatus = 3
               THEN LTRIM (ISNULL(REPLACE(REPLACE(REPLACE(RefCredStat.Status, Char(10),''),Char(13),''),',',''),'')) + ' ('
                    + CONVERT(VARCHAR, l.lastmodifiedDate, 101) + ')'
               ELSE LTRIM (ISNULL(REPLACE(REPLACE(REPLACe(RefCredStat.Status, Char(10),''),Char(13),''),',',''),''))
          END ) as [Credential Status]
		  ,duplicatelicense,donotcredential
			from hevn..license l with (nolock) 
INNER JOIN hevn..EmployeeRecord E WIth(NOLOCK) ON L.SSN = E.SSN and L.Employer_ID = E.EmployerID
inner join Client c on employerid = clno
inner join hevn..licensetype lt WIth(NOLOCK) on l.LicenseTypeID = LT.LicenseTypeID
			 LEFT JOIN hevn.DBO.refCredentialStatus RefCredStat WIth(NOLOCK) ON l.CredentialingStatus = RefCredStat.refCredentialStatusID
			 where licenseid in (  select distinct Apno from TCHAppno)
			 and EndDate IS NULL
			 order by lt.ItemValue
			 
truncate table TCHAppno
			-- truncate table #TABLE1
END
