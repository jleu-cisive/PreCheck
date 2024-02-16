
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 2/27/2013
-- Description:	get the reftype by section, if does not exist create reftype
/*
dbo.PrecheckFramework_GetApplRefTypeIdBySection 'Education'
*/
-- =============================================
CREATE PROCEDURE [dbo].[PrecheckFramework_GetApplRefTypeIdBySection] 
	-- Add the parameters for the stored procedure here
	--@sectionName varchar(50) 
	
AS
declare @refTypeId int = 0
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;		
	select refApplFileTypeId,Description,Abbreviation into #temp
	from [dbo].[refApplFileType]
	
	select * from #temp
	
	drop table #temp	
	--set @refTypeId = (select refApplFileTypeId from #temp rf where RTRIM(LTRIM(@sectionName)) = RTRIM(LTRIM(rf.Description)))    
 --   -- Insert statements for procedure here	
	--if (IsNull(@refTypeId,0) = 0)
	--	BEGIN		
	--		insert into 
	--			[dbo].[refApplFileType](Description,Abbreviation) 
	--		values 
	--			(@sectionName,
	--			 Upper(LEFT(@sectionName,3))
	--			 )		
	--		set @refTypeId = SCOPE_IDENTITY()
	--	END
	--select @refTypeId as RefTypeId
END

