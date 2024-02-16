-- =============================================
-- Author:		<Karan Sen>
-- Create date: <10-09-2022>
-- Description:	<This will return sections that needed to be verified by operation team>
-- Modify date: 10/19/2022 by schapyala.
-- Modification: Returing RequestCLNO and checking for configuration to strictly enforce requirements and setting values accordingly
-- Select * From ClientJobRequirementBySection(6799296)
-- =============================================
CREATE FUNCTION [dbo].[ClientJobRequirementBySection](
	@Apno INT
)
    RETURNS @Data TABLE (
        ApNo int,ClientId int,RequestClientID int,hasEmploymentRequirement bit,hasEducationRequirement bit,hasLicenseRequirement bit,hasOrderJobRequirement bit
		,ExcludeEmployment bit,ExcludeEducation bit,ExcludeLicense bit
    )
AS
BEGIN
Declare @License int=0
Declare @Employment int=0
Declare @Education int=0

/*------------------------------Uncomment Below code for further enhancing the logic for dynamic clients-------------------------------*/

--Select Top 1 @License = al.ApplicantLicenseId
--	from [Enterprise].[dbo].OrderJobRequirement_ApplicantLicense al with(nolock)
--	inner join [Enterprise].[dbo].ApplicantLicense ae with(nolock) on al.ApplicantLicenseId=ae.ApplicantLicenseId
--	inner join [Enterprise].[dbo].Applicant app with(nolock) on app.ApplicantId=ae.ApplicantId
--	where app.ApplicantNumber=@ApNo and al.IsActive=1

--Select TOp 1 @Employment = oae.OrderJobRequirement_ApplicantEmploymentId
--	from [Enterprise].[dbo].OrderJobRequirement_ApplicantEmployment oae with(nolock)
--	inner join [Enterprise].[dbo].ApplicantEmployment ae with(nolock) on oae.ApplicantEmploymentId=ae.ApplicantEmploymentId
--	inner join [Enterprise].[dbo].Applicant app with(nolock) on app.ApplicantId=ae.ApplicantId
--	where app.ApplicantNumber=@ApNo and oae.IsActive=1

--Select TOp 1 @Education = oae.OrderJobRequirement_ApplicantEducationId
--	from [Enterprise].[dbo].OrderJobRequirement_ApplicantEducation oae with(nolock)
--	join [Enterprise].[dbo].ApplicantEducation ae with(nolock) on oae.ApplicantEducationId=ae.ApplicantEducationId
--	join [Enterprise].[dbo].Applicant app with(nolock) on app.ApplicantId=ae.ApplicantId
--	where app.ApplicantNumber=@ApNo and oae.IsActive=1

Declare @IsOrderJobRequirement int=1,@ClientId int,@RequestClientID Int
	Select 
	--Uncomment the below line, this as when this needs to be dynamically derived. For GHR is not needed at this time.
	--@IsOrderJobRequirement= Count(OrderJobRequirementId),
	@ClientId=odr.ClientId , 
	@RequestClientID = IOR.CLNO
	From [Enterprise].[dbo].Applicant app with(nolock)
	join [Enterprise].[dbo].[Order] odr with(nolock) on odr.OrderId=app.OrderId
	--Uncomment the below line, this as when this needs to be dynamically derived. For GHR is not needed at this time.
	--join [Enterprise].dbo.[OrderJobRequirement] ojr with(nolock) on app.OrderId=ojr.OrderId 
	join Integration_ordermgmt_Request IOR  with (nolock) on app.applicantnumber = IOR.Apno  
	where app.applicantnumber=@ApNo
	group by odr.ClientId,IOR.CLNO



/*---------- Begin Comment-------------------------------------------------------------------------------------
This is where any additional(complex) business logic could be implemented in the future to exclude the specific 
components being send to zip crim.
-------------------------------------------------------------------------------------------------------------*/

Declare @ExcludeEmployment bit,@ExcludeEducation bit,@ExcludeLicense bit
Declare @StrictlyEnforceCICRequirements varchar(5)  = 'false'

Select @StrictlyEnforceCICRequirements = Value From ClientCOnfiguration 
where configurationkey='ZipCrim_StrictlyEnforceCICRequirements' and CLNO = @RequestClientID

--When configuration is set to strictly enforce, always exclude employment, education and license from sending to zipcrim
If @StrictlyEnforceCICRequirements  = 'True'
	Select @ExcludeEmployment= 1,@ExcludeEducation=1,@ExcludeLicense=1
else
	Select @ExcludeEmployment= 0,@ExcludeEducation=0,@ExcludeLicense=0

	--Select @ExcludeEmployment= Case when @Employment>0 then 1 else 0 end,@ExcludeEducation=Case when @Education>0 then 1 else 0 end,
	--@ExcludeLicense=Case when @License>0 then 1 else 0 end
/*----------- End Comment-------------------------------------------------------------------------------------*/


insert into @Data values(@Apno,@ClientId,@RequestClientID,(Case when @Employment>0 then 1 else 0 end),(Case when @Education>0 then 1 else 0 end),
(Case when @License>0 then 1 else 0 end),(Case when @IsOrderJobRequirement>0 then 1 else 0 end),
@ExcludeEducation,@ExcludeEmployment,@ExcludeLicense)

Return

End