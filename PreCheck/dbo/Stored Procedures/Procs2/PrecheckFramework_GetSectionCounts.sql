
--dbo.PrecheckFramework_GetSectionCounts 2111122

CREATE procedure [dbo].[PrecheckFramework_GetSectionCounts](@apno int)
as

select Section,SectionCount from
(
select 'Employment' as Section,count(EmplId) as SectionCount from dbo.Empl where apno = @apno
Union All
select 'Education' as Section,count(EducatId) as SectionCount from dbo.Educat where apno = @apno
Union All
select 'Licensing' as Section,count(ProfLicId) as SectionCount from dbo.ProfLic where apno = @apno
Union All
select 'PersonalReference' as Section,count(PersRefId) as SectionCount from dbo.PersRef where apno = @apno) secTbl
group by Section,SectionCount





