
CREATE procedure [PRECHECK\DDegenaro].[Integration_Verification_GetApno]
(
@tranid varchar(30)
)
AS
set ARITHABORT ON
--set @tranid = '023156968'
select top 1 SSN,apno,first,last,DOB from appl where Replace(SSN,'-','') in (
select  top 1 SSN from dbo.Integration_Verification_Transaction 
cross apply ResponseXml.nodes('declare namespace n="http://xml.studentclearinghouse.org/ws/services/DegreeVerify";//n:DetailRs') as T(Nodes)
where  	T.Nodes.value('declare namespace n="http://xml.studentclearinghouse.org/ws/services/DegreeVerify";n:TransId[1]','varchar(30)') = @tranid
and VerificationCodeIDType = 'Education'
ORDER BY CreatedDate)
