




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[us_in_addComponentToApplication]
	-- Add the parameters for the stored procedure here
	(@APNO int,@PackageComponentID int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

BEGIN TRANSACTION;

if @PackageComponentID = 5 --ADD ALL LICENSES
	BEGIN
		INSERT INTO PreCheck.dbo.ProfLic 
		(
			 apno, Lic_type,
			Lic_no, state, Expire,isonreport, Priv_Notes
		)
select  @apno
			,a.LicenseType
			,a.LicenseNumber
			,case when a.isNational = 1 then 'National' else s.abbreviation end 
			,a.LicenseExpire,1, CONVERT(varchar(20),getDate(),110) + ': VendorCheck Rescreen Indv License'
		from VendorCheck.dbo.Licenses a
		left outer join VendorCheck.dbo.States s on a.licensestate = s.stateid
		where a.employeeid = (select subjectid from VendorCheck.dbo.verification v where appno = @APNO)



	
	END
ELSE IF @PackageComponentID = 3 -- SEXOFFENDER
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
	IF @PackageComponentID = 1 -- CRIMINAL
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
           ,'VendorCheck Upgrade Service'
           ,6 --alert type is criminal rescreen
           ,0 
           ,getdate()
           ,null)

		END
ELSE 
	IF @PackageComponentID = 2 --SANCTION CHECK
	BEGIN

INSERT INTO PreCheck.dbo.MEDINTEG
(APNO,SectStat,CreatedDate)
VALUES
(@APNO,'0',getDate())


	END


COMMIT TRANSACTION;


END





