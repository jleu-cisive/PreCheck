

CREATE Proc [dbo].[FormAdverseStatusHistory]            
@aaid int,
@statusgroup varchar(50)  = 'AdverseAction'
As
Declare @ErrorCode int

if (@statusgroup = 'AdverseAction')
Begin
select aah.AdverseActionHistoryID as aahid,aah.AdverseActionID as aaid,aah.StatusID,
       refas.Status,aah.UserId,aah.AdverseContactMethodID as acmid,
       refacm.Method,aah.Comments,aah.[Date],
       aah.adversechangetypeid,refact.adversechangetype 
FROM AdverseActionHistory aah INNER JOIN refAdverseStatus refas ON aah.StatusID = refas.refAdverseStatusID 
LEFT OUTER JOIN refAdverseContactMethod refacm ON aah.AdverseContactMethodID = refacm.AdverseContactMethodID 
LEFT OUTER JOIN refadversechangetype refact ON aah.adversechangetypeid = refact.adversechangetypeid
WHERE aah.AdverseActionID=@aaid 
AND
refas.statusGroup = @statusgroup
order by aah.[date] desc

End

else if (@statusgroup = 'FreeReport')
Begin


select aah.AdverseActionHistoryID as aahid,aah.AdverseActionID as aaid,aah.StatusID,
       refas.Status,aah.UserId,aah.AdverseContactMethodID as acmid,
       refacm.Method,aah.Comments,aah.[Date],
       aah.adversechangetypeid,refact.adversechangetype 
FROM AdverseActionHistory aah INNER JOIN refAdverseStatus refas ON aah.StatusID = refas.refAdverseStatusID 
LEFT OUTER JOIN refAdverseContactMethod refacm ON aah.AdverseContactMethodID = refacm.AdverseContactMethodID 
LEFT OUTER JOIN refadversechangetype refact ON aah.adversechangetypeid = refact.adversechangetypeid
WHERE aah.AdverseActionID=@aaid 
AND
refas.statusGroup = @statusgroup
order by aah.[date] desc
End

