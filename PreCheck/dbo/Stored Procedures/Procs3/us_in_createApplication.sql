













-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[us_in_createApplication] 
	-- Add the parameters for the stored procedure here
	(@verificationid int,@return_Value int = 0 OUTPUT)
AS
BEGIN

SET XACT_ABORT ON;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @APNO int;
DECLARE @PKGID int;
DECLARE @CLNO int;




IF (SELECT count(*) from VendorCheck.dbo.Verification where verificationid = @verificationid and appno is not null) > 0
BEGIN
SELECT @return_Value = 0;
RETURN @return_Value;
END


BEGIN TRANSACTION;

SELECT @PKGID = (SELECT ClientPackageID from VendorCheck.dbo.Verification where verificationid = @verificationid);

--INSERT APPLICATION RECORD
   INSERT INTO PreCheck.dbo.Appl 
(
	apstatus, clno ,EnteredVia, ApDate ,	  
	last,	first ,	middle ,
	alias1_first, alias1_middle, alias1_last,
	alias2_first, alias2_middle, alias2_last,
	alias3_first, alias3_middle, alias3_last,
	alias4_first, alias4_middle, alias4_last, 
	SSN,	DOB ,	dl_number ,	dl_State ,
	needsreview, 
	addr_Street  ,	City ,	state ,
	Zip ,Phone,CellPhone,Priv_Notes,PackageID,Email
)
SELECT  CASE
			WHEN p.paymenttypeid = 2 THEN 'M'
			ELSE 'P'
		END
	,f.clno
	,'VendorCK'
	,getdate()	 
	,e.lastname 
	,e.firstname 
	,e.middlename 
	,e.alias1_first
	,e.alias1_middle
	,e.alias1_last	
	,e.alias2_first
	,e.alias2_middle
	,e.alias2_last
	,e.alias3_first
	,e.alias3_middle
	,e.alias3_last	
	,e.alias4_first
	,e.alias4_middle
	,e.alias4_last		
	,substring(e.SSN,1,3) + '-' + substring(e.SSN,4,2) + '-' + substring(e.SSN,6,4)
	,e.DateOfBirth 
	,e.DriversLicenseNumber
	,substring(s.Abbreviation,1,2)	
	,'W1'
	,substring(e.address,1,30)  
	,substring(e.City,1,16) 
	,substring(ss.abbreviation,1,2)
	,substring(e.ZipCode ,1,5)
	,e.phonenumber
	,e.CellPhone	
	,v.Comment
	,v.ClientPackageID
	,e.Email
from VendorCheck.dbo.verification v
inner join VendorCheck.dbo.Employees e on v.subjectid = e.employeeid
inner join VendorCheck.dbo.Facilities f on v.facilityid = f.facilityid
left outer join VendorCheck.dbo.payment p on p.paymentid = v.chargeid
left outer join VendorCheck.dbo.States s on e.driverslicensestateid = s.stateid
left outer join VendorCheck.dbo.States ss on e.stateid = ss.stateid	
where v.verificationid = @verificationid


--STORE APPLICATION NUMBER
select @APNO = @@IDENTITY
select @CLNO = (SELECT clno from PreCheck.dbo.Appl where apno = @APNO)

--SEX OFFENDER
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 3) > 0
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



--CRIMINAL







--PROFESSIONAL LICENSES
--Check if Package gets License by PackageComponentID
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 5) > 0
BEGIN
insert into PreCheck.dbo.ProfLic 
(
	 apno, Lic_type,
	Lic_no, state, Expire,isonreport
)
select  @APNO
	,a.LicenseType
	,a.LicenseNumber
	,CASE WHEN a.isNational = 1 THEN 'NATIONAL' ELSE s.Abbreviation END
	,a.LicenseExpire,1
from VendorCheck.dbo.Licenses a
inner join VendorCheck.dbo.verification v on a.employeeid = v.subjectid
left outer join  VendorCheck.dbo.States s on s.StateID = a.LicenseState
where v.verificationid = @verificationid
END

--SANCTION CHECK
--Check if Package gets sanction check by PackageComponentID
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 2) > 0
BEGIN
INSERT INTO PreCheck.dbo.MEDINTEG
(APNO,SectStat,CreatedDate)
VALUES
(@APNO,'0',getDate())
END


--Fac Policy Acceptance
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 4) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,4
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,10 --alert type fac policy acceptance
           ,0 
           ,getdate()
           ,null)

		END

--Training
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 7) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,7
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,11 --HIPAA Training Verification
           ,0 
           ,getdate()
           ,null)

		END
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 8) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,8
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,12 --Product Training Verification
           ,0 
           ,getdate()
           ,null)

		END
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 9) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,9
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,13 --OR Protocol Training Verification
           ,0 
           ,getdate()
           ,null)

		END
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 10) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,10
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,14 --Blood Borne Pathogen Training Verification
           ,0 
           ,getdate()
           ,null)

		END
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 11) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,11
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,15 --Aseptic Principles Training Verification
           ,0 
           ,getdate()
           ,null)

		END
--IMMUNIZATIONS
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 12) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,12
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,16 --Hep B
           ,0 
           ,getdate()
           ,null)

		END
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 13) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,13
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,17 --Influenza
           ,0 
           ,getdate()
           ,null)

		END
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 14) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,14
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,18 --MMR Immunization
           ,0 
           ,getdate()
           ,null)

		END
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 15) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,15
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,19 --Varicella Immunization
           ,0 
           ,getdate()
           ,null)

		END
if (SELECT COUNT(*) FROM PreCheck.dbo.ClientPackageComponent c
inner join clientpackages cp on c.clientpackagesid = cp.clientpackagesid
WHERE cp.packageid = @PKGID and cp.clno = @CLNO and packagecomponentid = 16) > 0
BEGIN
			INSERT INTO Precheck.[dbo].[ApplAlerts]
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
           ,16
           ,null
           ,0
           ,null
           ,null
           ,0
           ,'VendorCheck Create Application'
           ,20 --Tuberculosis Immunization
           ,0 
           ,getdate()
           ,null)

		END
--UPDATE Verfication table with application number
--UPDATE softtek-sql.VendorCheck.dbo.verification set appno = @APNO where verificationid = @verificationid;

--Update VendorCheck Status
--DECLARE @pass bit;
--SELECT @pass = 1;
--IF (select apstatus from PreCheck.dbo.appl where apno = @APNO) = 'M'
--	SELECT @pass = 0;
--INSERT INTO softtek-sql.VendorCheck.dbo.VerificationLog (VerificationID,VerificationStatusID,Timestamp,UpdatedBy,Comments)
--			    VALUES (@verificationid,CASE WHEN @pass = 0 THEN 8 ELSE 7 END,getdate(),1,null);


COMMIT TRANSACTION;
IF @@ERROR <> 0 
BEGIN 
SELECT @return_Value = 0;
END 
ELSE
BEGIN
SELECT @return_Value = @APNO;
END


RETURN @return_Value;

END





































