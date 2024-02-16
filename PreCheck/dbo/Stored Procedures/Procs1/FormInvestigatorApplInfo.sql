CREATE Proc dbo.FormInvestigatorApplInfo
@apno int
as

select * from appl where apno=@apno