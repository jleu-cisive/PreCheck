-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 04/27/2018
-- Description:	List of Work Number/Talx searches that resulted in 'NO MATCHES FOUND'
-- =============================================
--dbo.rpt_WorkNumber_NoMatchesFound '05/01/2018','06/01/2018'
CREATE PROCEDURE [dbo].[rpt_WorkNumber_NoMatchesFound]
(@FromDate Date = '1/1/1900',
 @ToDate Date = '1/1/1900')
AS
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    --Deduce the No Match report for the previous month
    IF @FromDate = '1/1/1900'
    BEGIN
	   --First Day of Previous Month
	   SET @FromDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, current_timestamp) - 1,0 ) 
	   --First Day of Current Month
	   SET @ToDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    END

	SELECT DISTINCT 'xxx-xx' + RIGHT(vt.SSN,4) SSN,
	STUFF((SELECT DISTINCT '; ' + vs.VerificationCodeId
			FROM dbo.Integration_Verification_Transaction VS 
    WHERE VS.APNO = vt.apno 
    FOR XML PATH('')), 1, 1, '') EmployerCodes,	
	 min(vt.VerifiedDate) VerifiedDate, vt.apno
	FROM dbo.Integration_Verification_Transaction vt 
	WHERE (CAST(vt.CreatedDate AS Date) between @FromDate and  @ToDate) AND createddate >'05/01/2018' 
	AND vendorid=3
	AND VerificationCodeIDType='Employment' 
	AND (isnull(ResponseXML.value('(//SEVERITY)[2]','varchar(1000)'),ResponseXML.value('(//SEVERITY)[1]','varchar(1000)')) <> 'Error') 
	-- ANDResponseXML.value('(//MESSAGE)[1]','varchar(1000)') NOT IN  ('Employee not found in database.','Multiple individuals may be associated with this SSN.'))
	GROUP BY APNO,SSN
	HAVING  max(ISNULL(CAST(vt.IsFoundEmployerCode AS INT),0)) = 0


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF	
END
