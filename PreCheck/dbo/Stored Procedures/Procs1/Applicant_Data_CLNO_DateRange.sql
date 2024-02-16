/*
Procedure Name : Applicant_Data_CLNO_DateRange
Requested By   : Valerie Salazar
Developer      : Vairavan A
Created on     : 18-12-2023
Ticket no & Description : 120863 Fix Existing QReport: Applicant Data by CLNO AND DateRange (lmm.) 
Execution      : EXEC [Applicant_Data_CLNO_DateRange] '12/14/2023', '12/15/2023',0,'4:30'
-------------------------------------------------
Modified by : Vairavan
Modified Date : 20-12-2023
Ticket no  & Desc - 121056 Modify QReport: Applicant Data by CLNO AND DateRange (lmm.)
*/

CREATE PROCEDURE [dbo].[Applicant_Data_CLNO_DateRange]
	@StartDate DATETIME,
	@EndDate DATETIME,
	@CLNO Int,
	@AffiliateIDs varchar(MAX) = '0'
AS
Begin
set nocount on

 IF @CLNO = 0 
    Select @CLNO = NULL

IF @AffiliateIDs = '0' 
BEGIN  
	SET @AffiliateIDs = NULL  
END

    Select A.CLNO, 
		   C.[Name] ClientName,
		   First, 
		   Last,
		   Middle, 
		   a.Email as 'Applicant Email Address',--code added for ticket no - 121056
		   SSN,
		   DOB,
		   a.APNO as 'Report Number',--code added for ticket no - 121056
		   a.ApStatus as  'Report Status',--code added for ticket no - 121056
		   ApDate, 
		   CompDate as 'Complete Date',--code added for ticket no - 121056
		   CP.[Name] ProgramName,
		   PackageDesc 
	from DBO.Appl A with(nolock) 
	     inner join 
		 DBO.Client C with(NOLOCK) 
	on  A.CLNO = C.CLNO        
		 left join
		 DBO.clientProgram CP with(NOLOCK)
	ON  A.CLNO = CP.CLNO 
	AND A.ClientProgramID = CP.ClientProgramID      
		 left join
		 DBO.PackageMain PM with(NOLOCK)
	ON  A.PackageID = PM.PackageID  
	Where A.CLNO =  isnull(@CLNO,A.CLNO)
	AND   A.ApDate between @StartDate AND @EndDate
	and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))


set nocount off
END

