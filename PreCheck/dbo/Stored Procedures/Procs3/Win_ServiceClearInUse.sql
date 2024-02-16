
CREATE PROCEDURE [dbo].[Win_ServiceClearInUse]  AS
--Release Records to Users from Windows Service
Update Appl
Set NeedsReview = 'W2',inuse = null
where (needsreview = 'W1') and (inuse = 'Merlin_E')
Update Appl
Set NeedsReview = 'X2',inuse = null
where (needsreview = 'X1') and (inuse = 'Merlin_E')
Update Appl
Set NeedsReview = 'R2', inuse = null
where (needsreview = 'R1') and (inuse ='Merlin_E')
Update Appl
Set NeedsReview = 'S2', inuse = null
where (needsreview = 'S1') and (inuse = 'Merlin_E')

--added by schapyala on 5/5/13
--Section level inuse clear if more than an  halfhhour
update dbo.empl
Set InUse = null,inuse_timestamp=null
Where Datediff(minute,inuse_timestamp,current_timestamp) >= 30

update dbo.Educat
Set InUse = null,inuse_timestamp=null
Where Datediff(minute,inuse_timestamp,current_timestamp) >= 30

update dbo.persref
Set InUse = null,inuse_timestamp=null
Where Datediff(minute,inuse_timestamp,current_timestamp) >= 30

update dbo.proflic
Set InUse = null,inuse_timestamp=null
Where Datediff(minute,inuse_timestamp,current_timestamp) >= 30

