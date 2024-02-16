-- =============================================
-- Author:		An Vo
-- Create date: 4/24/2018
-- Description:	This stored procedure attempts to count the number of licenses that are automated 
-- as well as the number of the licenses that are *not* automated.
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_GetLicenseCount]
	 @StartDate datetime,
	 @EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Result Table
	(
	   SectionKeyId varchar(50),
	   LicenseCount int,
	   IsAutomationEnabled varchar(3) 
	)
	
	select concat(s.ItemValue,'-', lt.ItemValue) as SectionKeyId, s.ItemValue as IssuingState, lt.LicenseTypeID as LicenseTypeId 
    into #all_sectionkeyid_combinations
    from [HEVN].[dbo].[State] s, [HEVN].[dbo].[LicenseType] lt
    where lt.IsCredentiable = 1
    and lt.IsActive = 1
    and lt.ItemValue is not null

	select a.SectionKeyId, a.IssuingState, a.LicenseTypeId
	into #not_in_mapping_table
	from #all_sectionkeyid_combinations a left join [Precheck].[dbo].[DataXtract_RequestMapping] b on a.SectionKeyId = b.SectionKeyID where b.SectionKeyID is null
	or IsAutomationEnabled = 0

	select License.IssuingState, License.LicenseTypeID, count(LicenseID) as LicenseCount
	into #license_count_not_automated
	from [HEVN].[dbo].[License]
	join(select IssuingState, LicenseTypeId from #not_in_mapping_table) table2
	on License.IssuingState = table2.IssuingState
	and License.LicenseTypeID = table2.LicenseTypeId
	where License.IssuingState <> ''
	and License.Type <> ''
	group by License.IssuingState, License.LicenseTypeID

	select SectionKeyId, max(Total_Records) as LicenseCount
	into #license_counts_automated
	from DataXtract_Logging (nolock)
	where SectionKeyId in (select sectionKeyid from Dataxtract_RequestMapping where Section = 'License' and IsAutomationEnabled = 1) 
	and DateLogRequest >= @StartDate
	and DateLogRequest <= @EndDate 
	and Section in('SBM_Base','SBM')
	group by SectionKeyId
	order by SectionKeyId

	insert into @Result (SectionKeyId, LicenseCount, IsAutomationEnabled)
	select concat(#license_count_not_automated.IssuingState,'-', licenseType.ItemValue), #license_count_not_automated.LicenseCount, 'No'
	from #license_count_not_automated inner join [HEVN].[dbo].LicenseType on #license_count_not_automated.LicenseTypeID = licenseType.LicenseTypeID

	insert into @Result (SectionKeyId, LicenseCount, IsAutomationEnabled)
	select SectionKeyId, LicenseCount, 'Yes'
	from #license_counts_automated

	select * from @Result order by SectionKeyId

	drop table #all_sectionkeyid_combinations
	drop table #not_in_mapping_table
	drop table #license_count_not_automated
	drop table #license_counts_automated
END
