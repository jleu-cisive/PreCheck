create procedure dbo.Integration_GetXsltCommon
as
select top 1 * from dbo.[XSLFileCache] where CLNO = 0