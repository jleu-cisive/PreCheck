

CREATE PROCEDURE dbo.StateBoardEmailMisMatch @SourceID int AS


-- This will send email to Superviser - JS -9/21/2005

SELECT     'shrek' AS EmailServer, 'StateBoard Monitoring' AS EmailSubject, 'StateBoardMonitoring@precheck.com' AS EmailFrom, 
 'StateBoardMonitoring@precheck.com' AS Emailto, 'has license entries that do not match please review' AS EmailBody, dbo.VWlicenseAuthority.SourceName
FROM         VWlicenseAuthority  INNER JOIN
                      dbo.StateBoardDisciplinaryRun ON dbo.VWlicenseAuthority.StateBoardSourceID = dbo.StateBoardDisciplinaryRun.StateBoardSourceInfoID
WHERE     (dbo.StateBoardDisciplinaryRun.StateBoardDisciplinaryRunID = @SourceID)
