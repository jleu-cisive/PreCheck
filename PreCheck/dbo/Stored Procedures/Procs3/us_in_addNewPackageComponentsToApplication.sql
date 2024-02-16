









-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[us_in_addNewPackageComponentsToApplication]
	-- Add the parameters for the stored procedure here
	(@upgraderequestid int, @APNO int,@OldClientPackagesID int, @NewClientPackagesID int,@returnvalue int = 0 OUTPUT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

    

DECLARE @PackageComponentID int
DECLARE @NEWPKGID int;
DECLARE @OLDPKGID int;
DECLARE @CLNO int;
SELECT @CLNO = (select clno from appl where apno = @APNO);

SELECT @NEWPKGID = (SELECT cp.clientpackagesid from clientpackages cp where cp.packageid = @NewClientPackagesID AND cp.clno = @CLNO)

SELECT @OLDPKGID = (SELECT cp.clientpackagesid from clientpackages cp where cp.packageid = @OldClientPackagesID AND cp.clno = @CLNO)


DECLARE Section_Cursor CURSOR FOR

SELECT PackageComponentID from ClientPackageComponent
 where clientPackagesID = @NEWPKGID and PackageComponentID not in 
(SELECT PackageComponentID from ClientPackageComponent
 where clientPackagesID = @OLDPKGID) 
BEGIN TRANSACTION;
OPEN Section_Cursor;
FETCH NEXT FROM Section_Cursor INTO @PackageComponentID;
IF @@FETCH_STATUS = 0
--REOPEN APPLICATION AND SET NEW PACKAGE ID
	--Update appl set apstatus = 'P',packageid = @NewClientPackagesID where apno = @APNO;
UPDATE dbo.Appl set inuse = 'VC_RESCR',Apstatus = 'P',packageid = @NewClientPackagesID,reopendate = getdate(),origcompdate = CASE WHEN origcompdate is null THEN compdate ELSE origcompdate END
 WHERE APNO = @APNO AND inuse is null AND apstatus = 'F';
IF @@ROWCOUNT <> 0
BEGIN	

--ADD SECTIONS
WHILE @@FETCH_STATUS = 0
   BEGIN
	--add component based on PackageComponentID	
	EXEC dbo.us_in_addComponentToApplication @APNO,@PackageComponentID;

      FETCH NEXT FROM Section_Cursor INTO @PackageComponentID;
   END;


update vendorcheck.dbo.upgraderequest set processed = 1 where upgraderequestid = @upgraderequestid
SELECT @returnvalue = 1;
END
CLOSE Section_Cursor;
DEALLOCATE Section_Cursor;
COMMIT TRANSACTION;
 --RELEASE APPLICATION
UPDATE dbo.Appl set inuse = null WHERE APNO = @apno;

RETURN @returnvalue
END










