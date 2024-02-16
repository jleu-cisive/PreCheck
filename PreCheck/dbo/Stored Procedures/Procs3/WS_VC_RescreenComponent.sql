










-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[WS_VC_RescreenComponent] 
	-- Add the parameters for the stored procedure here
	(@RescreeningRequestID int, @apno int,@PackageComponentID int,@itemid int = null,@returnvalue int = 0 output)
AS
BEGIN
	SET XACT_ABORT ON;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--LOCK APP TO REOPEN

UPDATE PreCheck.dbo.Appl set inuse = 'VC_RESCR',Apstatus = 'P',reopendate = getdate(),origcompdate = CASE WHEN origcompdate is null THEN compdate ELSE origcompdate END
 WHERE APNO = @apno AND inuse = null AND apstatus = 'F';
IF @@ROWCOUNT = 0
	RETURN @returnvalue



BEGIN TRANSACTION;
--HANDLE RESCREEN

IF @itemid is not null
BEGIN

	
	IF @PackageComponentID = 5 --RESCREEN INDIVIDUAL LICENSE
		BEGIN
		
		INSERT INTO PreCheck.dbo.ProfLic 
		(
			 apno, Lic_type,
			Lic_no, state, Expire,isonreport, Priv_Notes
		)
--pull from vendorcheck database instead of precheck
--		select  @apno
--			,a.Lic_Type
--			,a.Lic_No
--			,a.State
--			,a.Year
--			,a.Expire, CONVERT(varchar(20),getDate(),110) + ': VendorCheck Rescreen Indv License'
--		from PreCheck.dbo.ProfLic a
--		where a.ProfLicID = @itemid
select  @apno
			,a.LicenseType
			,a.LicenseNumber
			,case when a.isNational = 1 then 'National' else s.abbreviation end 
			,a.LicenseExpire,1, CONVERT(varchar(20),getDate(),110) + ': VendorCheck Rescreen Indv License'
		from VendorCheck.dbo.Licenses a		
		left outer join VendorCheck.dbo.States s on a.licensestate = s.stateid
		where a.LicenseID = @itemid		

		SELECT @returnvalue = 1;

		END


END
--WITHOUT ITEMID
ELSE
BEGIN


	if @PackageComponentID = 5 --RESCREEN ALL LICENSES
	BEGIN
		INSERT INTO PreCheck.dbo.ProfLic 
		(
			 apno, Lic_type,
			Lic_no, state, Expire,isonreport, Priv_Notes
		)
--		select  @apno
--			,a.Lic_Type
--			,a.Lic_No
--			,a.State
--			,a.Year
--			,a.Expire, CONVERT(varchar(20),getDate(),110) + ': VendorCheck Rescreen Indv License'
--		from PreCheck.dbo.ProfLic a
--		where a.apno = @apno
select  @apno
			,a.LicenseType
			,a.LicenseNumber
			,case when a.isNational = 1 then 'National' else s.abbreviation end 
			,a.LicenseExpire,1, CONVERT(varchar(20),getDate(),110) + ': VendorCheck Rescreen Indv License'
		from VendorCheck.dbo.Licenses a
		left outer join VendorCheck.dbo.States s on a.licensestate = s.stateid
		where a.employeeid = (select subjectid from VendorCheck.dbo.verification v inner join rescreeningrequest r on v.verificationid = r.verificationid
		where rescreeningRequestid = @rescreeningrequestid)

	SELECT @returnvalue = 1;
	END
	ELSE
	IF @PackageComponentID = 2 --RESCREEN SANCTIONCHECK
		BEGIN
			IF(SELECT count(*) FROM MedInteg WHERE apno = @apno) > 0
				BEGIN
					Update MedInteg set SectStat = '9' WHERE apno = @apno
					--Update Appl set priv_notes = CONVERT(varchar(20),getDate(),110) + ': SanctionCheck Rescreen' + priv_notes WHERE apno = @apno


				END
			ELSE
				INSERT INTO MedInteg (apno,sectstat)
				VALUES (@apno,'9')
				--Update Appl set priv_notes = CONVERT(varchar(20),getDate(),110) + ': SanctionCheck Rescreen' + priv_notes WHERE apno = @apno

		END
	ELSE
	IF @PackageComponentID = 3 --RESCREEN SEX OFFENDER
		BEGIN
			DECLARE @BigCounty varchar(75)
			DECLARE @CrimID int
			DECLARE @State varchar(2)
			SELECT @State = State FROM PreCheck.dbo.Appl WHERE APNO = @apno

			SELECT @BigCounty=county FROM PreCheck.dbo.COUNTIES WHERE CNTY_NO=2480

			insert into PreCheck.dbo.Crim (Apno, CNTY_NO, County) values (@Apno, 2480, @BigCounty)
			select @CrimID = @@IDENTITY
			exec PreCheck.dbo.testfaxingsexoffender @apno,@Bigcounty,2480, @CrimID,@State





		END
	ELSE
	IF @PackageComponentID = 1 -- RESCREEN CRIMINAL
		BEGIN
			INSERT INTO [Precheck].[dbo].[ApplAlerts]
           ([APNO]
           ,[PackageComponentID]
           ,[ItemID]
           ,[Cleared]
           ,[ClearedBy]
           ,[ClearedDate]
           ,[Billed]
           ,[Source]
           ,[refAlertTypeID]
           ,[refApplAlertStatusID]
           ,[CreatedDate]
           ,[Comment])
     VALUES
           (@APNO
           ,1
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Rescreening Service'
           ,1 --alert type is criminal rescreen
           ,0
           ,getdate()
           ,null)

		END
		

END


--LOG Rescreening into log table????




--Update RescreeningRequestID to processed
Update VendorCheck.dbo.RescreeningRequest set Processed = 1 where RescreeningRequestId = @RescreeningRequestId

SELECT @returnvalue = 1;
COMMIT TRANSACTION;

 --RELEASE APPLICATION
UPDATE PreCheck.dbo.Appl set inuse = null WHERE APNO = @apno;


RETURN @returnvalue
   
END











