
--Modified bY Radhika Dereddy on 01/02/2018
--To show only the records for AdverserAction and not the Free Report.
--EXEC [Web_AdverseStatusHistory] 3902443, '0678'

CREATE Proc [dbo].[Web_AdverseStatusHistory]            
@apno int,
@ssn  varchar(11)
As
Declare @ErrorCode int

--select refas.Status,aah.[Date] --,isnull(aah.Comments,'') as Comments
--  from AdverseActionHistory aah,adverseaction aa,refAdverseStatus refas,Appl a
-- where aa.apno=a.apno
--   and aa.adverseactionid=aah.AdverseActionID
--   and aah.StatusID=refas.refAdverseStatusID
--  -- and aah.Source = 'AdverseAction' --added by Radhika on 01/02/2018
--   and aa.apno=@apno 
--   and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn
--   and aah.adversechangetypeid=1
--order by aah.[date] desc


-- changed by kiran 1/2/2018 -- remove the cross reference for Free report table
select refas.Status,aah.[Date] 
 from appl a inner join  adverseaction aa  on a.apno=aa.apno
 inner join AdverseActionHistory aah on aa.adverseactionid=aah.AdverseActionID
inner join refAdverseStatus refas on  aah.StatusID=refas.refAdverseStatusID and refas.statusGroup = 'AdverseAction'
 where a.apno=@apno and substring(a.ssn,len(rtrim(a.ssn))-3,4)=@ssn 
order by aah.[date] desc




