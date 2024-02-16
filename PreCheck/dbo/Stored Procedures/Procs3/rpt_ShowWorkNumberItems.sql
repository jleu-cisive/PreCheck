/**********************************************************
 --Modified By: Amy Liu on 06/11/2018 to fix error. HDT34402
--[rpt_ShowWorkNumberItems] '04/30/2018','05/01/2018'
--[rpt_ShowWorkNumberItems] @APNO=4104861,@IsFound = 2
********************************************************/

CREATE PROCEDURE [dbo].[rpt_ShowWorkNumberItems]
( @FromDate Date = '1/1/1900',
 @ToDate Date = '1/1/1900',
 @APNO INT = 0,
 @IsFound INT = 1
)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF @FromDate in ('1/1/1900' ,'')
	SET @FromDate = NULL

IF @ToDate in ('1/1/1900' ,'')
	SET @ToDate = NULL


DECLARE @WorkNumberItems TABLE (APNO INT,VerficationTransactionId INT, VerifiedDate DATETIME,
[EmployerCode (Employer) - Checked] VARCHAR(max),
VerificationCodeID VARCHAR(20),Employer_Code VARCHAR(20),Employer_Name VARCHAR(1000),Address1 VARCHAR(300), Address2 VARCHAR(300),
City VARCHAR(300),EmployerState VARCHAR(20),Zip VARCHAR(10),Position_Sought VARCHAR(100),Division VARCHAR(100),Date_Most_Recent_Hire VARCHAR(10),Date_Original_Hire VARCHAR(10),
End_Date_Of_Employment VARCHAR(10),Total_Length_Of_Service VARCHAR(10),IsFound Bit)

INSERT INTO @WorkNumberItems
(
    APNO,[EmployerCode (Employer) - Checked],
	VerficationTransactionId,VerifiedDate,
    VerificationCodeID,
    Employer_Code,
    Employer_Name,
    Address1,
    Address2,
    City,
    EmployerState,
    Zip,
    Position_Sought,
    Division,
    Date_Most_Recent_Hire,
    Date_Original_Hire,
    End_Date_Of_Employment,
    Total_Length_Of_Service,
	IsFound)
SELECT 
	apno,
   STUFF((SELECT '; ' + VS.VerificationSourceCode + ' (' + SourceVerifyName + ') - ' + CASE WHEN IsChecked=1 THEN 'True' ELSE 'False' END
    FROM dbo.Integration_Verification_SourceCode VS 
    WHERE VS.SectionKeyID IN (SELECT emplid FROM dbo.empl WHERE apno = vt.apno)
    and VS.refVerificationSource  = 'WorkNumber' 
    FOR XML PATH('')), 1, 1, '') [EmployerCode (Employer) - Checked],
    VerficationTransactionId,vt.verifieddate,vt.VerificationCodeId,
    Employer.Rec.value('(EMPLOYERCODE)[1]','VARCHAR(100)') Employer_Code,
	Employer.Rec.value('(NAME1)[1]','VARCHAR(1000)') Employer_Name,
	Employer.Rec.value('(ADDR1)[1]','VARCHAR(300)') Address_1,
	Employer.Rec.value('(ADDR2)[1]','VARCHAR(400)') Address_2,
	Employer.Rec.value('(CITY)[1]','VARCHAR(300)') City,
	Employer.Rec.value('(STATE)[1]','VARCHAR(20)') [State],
	Employer.Rec.value('(POSTALCODE)[1]','VARCHAR(10)') Zip_Code,
	Candidate.Detail.value('(POSITION-TITLE)[1]','VARCHAR(100)') Pos_Sought,
	Candidate.Detail.value('(DIVISIONCODE)[1]','VARCHAR(100)') Division,
CASE WHEN ISNULL(Candidate.Detail.value('(DTMOSTRECENTHIRE)[1]','varchar(100)'),'') = '' then '' else  SUBSTRING(Candidate.Detail.value('(DTMOSTRECENTHIRE)[1]','varchar(100)'),5, 2) + '/' + SUBSTRING(Candidate.Detail.value('(DTMOSTRECENTHIRE)[1]','varchar(100)') ,7,2) + '/' + SUBSTRING(Candidate.Detail.value('(DTMOSTRECENTHIRE)[1]','varchar(100)'),1, 4) end  Date_Most_Recent_Hire,
CASE WHEN ISNULL(Candidate.Detail.value('(DTORIGINALHIRE)[1]','VARCHAR(100)'),'') = '' then '' else SUBSTRING(Candidate.Detail.value('(DTORIGINALHIRE)[1]','VARCHAR(100)') ,5, 2) + '/' + SUBSTRING(Candidate.Detail.value('(DTORIGINALHIRE)[1]','VARCHAR(100)')  ,7,2) + '/' + SUBSTRING(Candidate.Detail.value('(DTORIGINALHIRE)[1]','VARCHAR(100)') ,1, 4) end Date_Original_Hire,
CASE WHEN isnull(Candidate.Detail.value('(DTENDEMPLOYMENT)[1]','VARCHAR(20)'),'') = '' then '' else SUBSTRING(Candidate.Detail.value('(DTENDEMPLOYMENT)[1]','VARCHAR(20)'),5, 2) + '/' + SUBSTRING(Candidate.Detail.value('(DTENDEMPLOYMENT)[1]','VARCHAR(20)') ,7,2) + '/' + SUBSTRING(Candidate.Detail.value('(DTENDEMPLOYMENT)[1]','VARCHAR(20)'),1, 4) end End_Date_Of_Employment,
Candidate.Detail.value('(TOTALLENGTHOFSVC)[1]','VARCHAR(20)') Total_Length_Of_Service,
IsFound = CASE WHEN vt.VerificationCodeId = Employer.Rec.value('(EMPLOYERCODE)[1]','VARCHAR(100)') THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) end
FROM dbo.Integration_Verification_Transaction vt     
CROSS APPLY vt.ResponseXML.nodes('//TSVRESPONSE_V100') as Tab(col)
CROSS APPLY Tab.col.nodes('TSVEMPLOYER_V100') AS Employer(Rec)
CROSS APPLY Tab.col.nodes('TSVEMPLOYEE_V100') AS Candidate(Detail)
WHERE ((CAST(vt.CreatedDate AS Date) between @FromDate and  @ToDate AND @FromDate IS NOT NULL AND @ToDate IS NOT NULL ) OR (APNO = @APNO AND IsNull(@APNO,0) <> 0))
and IsComplete=1 AND vendorid = 3


SELECT  wni.APNO, wni.VerifiedDate, wni.IsFound ,[EmployerCode (Employer) - Checked], wni.VerificationCodeID SearchCode, wni.Employer_Code, wni.Employer_Name, wni.Address1, wni.Address2, wni.City, wni.EmployerState, wni.Zip,  wni.Date_Most_Recent_Hire, wni.Date_Original_Hire, wni.End_Date_Of_Employment, wni.Position_Sought, wni.Division,wni.Total_Length_Of_Service
FROM @WorkNumberItems wni
WHERE wni.IsFound = CASE WHEN @IsFound = 2 THEN IsFound ELSE CAST(@IsFound AS BIT) END
AND CASE WHEN @APNO > 0 THEN  APNO ELSE @APNO END = @APNO
ORDER BY VerficationTransactionId



 
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF


