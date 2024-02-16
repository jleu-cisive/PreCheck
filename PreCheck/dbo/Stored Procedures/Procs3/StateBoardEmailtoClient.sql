

CREATE PROCEDURE StateBoardEmailtoClient AS


select 'shrek' as MailServer,aet.[From],'StateboardMonitoring@precheck.com'  as [To],
 aet.subject1 as subject ,'Nick Reimer' as ContactName,'NicholasReimer@precheck.com' as ContactEmail
from   AdverseEmailTemplate aet 
where aet.refAdverseStatusID=0 

--'StateBoardMonitoring@precheck.com'  as [To],
