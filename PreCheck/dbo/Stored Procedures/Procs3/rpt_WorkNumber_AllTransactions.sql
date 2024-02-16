-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 04/27/2018
-- Description:	List of Work Number/Talx transactions and the result status with the outcome
-- =============================================
--dbo.[rpt_WorkNumber_AllTransactions] '06/01/2018','07/01/2018'
CREATE PROCEDURE [dbo].[rpt_WorkNumber_AllTransactions]
(@FromDate Date = '1/1/1900',
 @ToDate Date = '1/1/1900')
AS
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    --Deduce the No Match report for the previous month
    IF @FromDate = '1/1/1900'
    Begin
	   --First Day of Previous Month
	   SET @FromDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, current_timestamp) - 1,0 ) 
	   --First Day of Current Month
	   SET @ToDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    END

	SELECT distinct 'xxx-xx' + RIGHT(vt.SSN,4) SSN,SSN ssn1,vendorid,	--ResponseXML,
	 (vt.VerifiedDate) ,CreatedDate, isnull(vt.apno,0) APNO,
	 case when iscomplete=0 then 'Internal Error' else isnull(ResponseXML.value('(//SEVERITY)[2]','varchar(1000)'),ResponseXML.value('(//SEVERITY)[1]','varchar(1000)')) END [ResultStatus]--,ResponseXML.value('(//SEVERITY)[2]','varchar(1000)')
	 ,case when iscomplete=0 then '' else ResponseXML.value('(//MESSAGE)[1]','varchar(1000)') end ResultStatusDescr,
	 case when iscomplete=0 then 0 ELSE (SELECT max(cast(isnull(v.IsFoundEmployerCode,0) AS int)) FROM  dbo.Integration_Verification_Transaction v where v.apno = vt.apno
	 AND (CAST(v.CreatedDate AS Date) between @FromDate and  @ToDate) AND v.createddate >'05/01/2018' GROUP BY v.apno) end VerificationOutcome
	FROM dbo.Integration_Verification_Transaction vt 
	WHERE (CAST(vt.CreatedDate AS Date) between @FromDate and  @ToDate) AND createddate >'05/01/2018' 
	AND isnull(vendorid,3)=3 AND VerificationCodeIDType='Employment' 
	AND vt.IsInternalVerification	 =0
	ORDER BY CreatedDate,SSN,isnull(vt.apno,0)


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF	
End