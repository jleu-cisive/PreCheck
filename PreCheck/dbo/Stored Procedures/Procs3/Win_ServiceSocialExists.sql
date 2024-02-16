
CREATE PROCEDURE [dbo].[Win_ServiceSocialExists] AS
--JS 12/13/2005
--- Only For Logging
--Insert into SocialCheckLog(apno,socialaction,socialDate) 
--select apno,'Windows_Service_Finish Called' ,getdate() from appl
--where InUse = 'Social_S' 
--------------------------------
-- Filter records for Social Process,And set inuse exclusively for Social Process
Update Appl
Set Inuse = 'Social_I'
where inuse = 'Social_S'

SET NOCOUNT ON
DECLARE  @apno  int,@priv_notes varchar(4000), @Clno INT,@SSN Varchar(11)
DECLARE  @ALLNotes varchar(4000)

-- Table varible to capture all the ITRV Clients - VD - 04/28/2016
DECLARE @ITRV_Clno TABLE
(
    Clno INT
)

-- Insert all the clients which qualify the Configurationkey
INSERT INTO @ITRV_Clno SELECT CLNO FROM dbo.ClientConfiguration WHERE ConfigurationKey = 'HCA_ITRV_SSN_Check' and Value = 'True'


DECLARE SSN_Cursor CURSOR FOR
	SELECT    a.apno,a.priv_notes, a.CLNO,a.SSN
	FROM      appl a 
	where a.InUse = 'Social_I' and a.SSN in (select ssn from appl where ssn is not null and  apno <> a.apno) 
OPEN SSN_Cursor

FETCH SSN_Cursor INTO @apno,@priv_notes,@Clno,@SSN

WHILE @@Fetch_Status = 0
   BEGIN
	   select @allnotes = isnull(@priv_notes ,'')
	   update  appl  
	   		   set priv_notes = CASE WHEN (@Clno IN  (select CLNO from @ITRV_Clno) and ((Select count(1) from Appl Where SSN = @SSN and CLNO = 12221 ) > 0))-- VD - 04/28/2016
									 THEN  '**Alert** SSN Already Exists for Account HCA Continental Division ITRV #12221**' + char(13) + char(10) + isnull(@allnotes ,'')
								ELSE '** SSN ALREADY EXISTS  **' + char(13) + char(10) + isnull(@allnotes,'')
								END 
								, inuse='Social_E'

	   --set priv_notes =  '** SSN ALREADY EXISTS  **' + char(13) + char(10) + @allnotes ,inuse='Social_E'
	   where apno = @apno
	  --*********** Only for Logging
	   --Insert into SocialCheckLog(apno,socialaction,socialDate) 
	   --values(@apno,'*** SSN ALREADY EXISTS ***' + char(13) + char(10) + @allnotes,getdate())
	   --*********** End 
	   FETCH SSN_cursor INTO @apno,@priv_notes, @Clno,@SSN
   END

CLOSE SSN_Cursor

DEALLOCATE SSN_Cursor
-- Release Application for Next WindowServiceProcess
Update Appl
set Inuse = 'Social_E'
--set Inuse = 'Merlin_E'
where Inuse = 'Social_I'

/*
07/17/2019- Yves Fernandes - Add instruction to check package and client instructions for zipcrim clients
*/

EXEC [dbo].[Win_Service_HandlePackageAndClientInstructionsforZipCrimClients]
