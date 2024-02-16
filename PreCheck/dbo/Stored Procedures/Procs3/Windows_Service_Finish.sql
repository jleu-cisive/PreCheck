CREATE PROCEDURE [dbo].[Windows_Service_Finish] AS
--JS 12/13/2005
--- Only For Logging
--Insert into SocialCheckLog(apno,socialaction,socialDate) 
--select apno,'Windows_Service_Finish Called' ,getdate() from appl
--where InUse = 'Merlin' and (NeedsReview = 'R1' or NeedsReview = 'W1' OR NeedsReview = 'X1' or NeedsReview = 'S1')
--- End of Logging
SET NOCOUNT ON
DECLARE  @apno  int,@priv_notes varchar(4000)
DECLARE  @ALLNotes varchar(4000)
DECLARE SSN_Cursor CURSOR FOR
SELECT    a.apno,a.priv_notes
FROM      appl a 
where a.InUse = 'Merlin' and (a.NeedsReview = 'R1' or a.NeedsReview = 'W1' OR a.NeedsReview = 'X1' or a.NeedsReview = 'S1')
and a.SSN in (select ssn from appl where ssn is not null and  apno <> a.apno) 
OPEN SSN_Cursor
FETCH SSN_Cursor INTO @apno,@priv_notes
WHILE @@Fetch_Status = 0
   BEGIN
   select @allnotes = isnull(@priv_notes ,'')
   update  appl  
   set priv_notes =  '** SSN ALREADY EXISTS  **' + char(13) + char(10) + @allnotes 
   where apno = @apno
  --*********** Only for Logging
   --Insert into SocialCheckLog(apno,socialaction,socialDate) 
   --values(@apno,'*** SSN ALREADY EXISTS ***' + char(13) + char(10) + @allnotes,getdate())
   --*********** End 
   FETCH SSN_cursor INTO @apno,@priv_notes
   END
CLOSE SSN_Cursor
DEALLOCATE SSN_Cursor
Update Appl
Set NeedsReview = 'W2',inuse = null
where (needsreview = 'W1') and (inuse = 'Merlin')
Update Appl
Set NeedsReview = 'X2',inuse = null
where (needsreview = 'X1') and (inuse = 'Merlin')
Update Appl
Set NeedsReview = 'R2', inuse = null
where (needsreview = 'R1') and (inuse ='Merlin')
Update Appl
Set NeedsReview = 'S2', inuse = null
where (needsreview = 'S1') and (inuse = 'Merlin')
