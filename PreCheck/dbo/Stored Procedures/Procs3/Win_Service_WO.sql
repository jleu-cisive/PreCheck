CREATE PROCEDURE Win_Service_WO AS
--Convert w2 to W3
Update Appl
Set NeedsReview = 'W2'
where (needsreview = 'W1') and (inuse = 'service')
and enteredby = 'web'
