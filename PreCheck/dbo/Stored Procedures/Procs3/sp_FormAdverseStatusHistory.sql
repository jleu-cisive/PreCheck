
CREATE Proc [dbo].[sp_FormAdverseStatusHistory]            
@aaid int
As
Declare @ErrorCode int

select aah.AdverseActionHistoryID as aahid,aah.AdverseActionID as aaid,aah.StatusID,
       refas.Status,aah.UserId,aah.AdverseContactMethodID as acmid,
       refacm.Method,aah.Comments,aah.[Date] 
FROM AdverseActionHistory aah INNER JOIN refAdverseStatus refas ON aah.StatusID = refas.refAdverseStatusID LEFT OUTER JOIN refAdverseContactMethod refacm ON aah.AdverseContactMethodID = refacm.AdverseContactMethodID
WHERE aah.AdverseActionID=@aaid
order by aah.[date] desc
