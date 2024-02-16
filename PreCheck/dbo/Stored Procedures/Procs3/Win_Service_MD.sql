CREATE PROCEDURE Win_Service_MD AS
--MD Anderson Convert X2 to X3

Update Appl
Set NeedsReview = 'X2'
where (needsreview = 'X1') and (inuse = 'service')