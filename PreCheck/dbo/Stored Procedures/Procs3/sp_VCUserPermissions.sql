

CREATE PROCEDURE [dbo].[sp_VCUserPermissions]
@userId varchar(50)=null,
@identifier int=0,
@module varchar(50)=null

as
BEGIN
set nocount ON
declare @sections varchar(20)=null
select @sections=Sections FROM VCUserPermissions where isactive=1 and UserID=@userId AND [Permissions] LIKE '%'+@module+'%'
--SELECT @sections
if(@sections<>'all'and @sections IS NOT NULL)
BEGIN
select top 1 1 as Active,NULL as AllPermissions FROM InvDetail_Reconciliation where isactive=1 and InvDetID=@identifier and @sections like '%'+cast(SectionId as VARCHAR(10))+'%' 
end
if(@sections='all' and @sections IS NOT NULL)
BEGIN
select top 1 1 as Active,NULL as AllPermissions
end
SET nocount off

end



