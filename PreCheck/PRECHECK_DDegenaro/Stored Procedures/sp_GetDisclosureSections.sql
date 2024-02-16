create procedure [PRECHECK\DDegenaro].sp_GetDisclosureSections(@clno int)
as

select DisclosureTypeId,DisclosureSectionName,DisclosureBlurb from dbo.ClientDisclosure dc
join dbo.refDisclosureSection refdc on refdc.DisclosureSectionId = dc.DisclosureTypeId
where clno = isnull(@clno,2135) 