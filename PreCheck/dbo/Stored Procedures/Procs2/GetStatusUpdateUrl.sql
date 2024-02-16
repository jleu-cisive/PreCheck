
CREATE procedure [dbo].[GetStatusUpdateUrl]
( @apno int)
as
select top 1  Url from [dbo].[Integration_StatusUpdate_Urls] where Apno = @apno order by CreateDate desc


