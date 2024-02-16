CREATE PROCEDURE Win_Service_DE AS

Update Appl
Set NeedsReview = 'R2'
where (needsreview = 'R1') and (inuse ='service')