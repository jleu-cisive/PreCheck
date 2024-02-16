
CREATE PROCEDURE [dbo].[FormTaskNewProjPriorityLevelUpdate] @Plevel int, @EstReturn int  AS

update taskqueuenew set prioritylevelid=@Plevel, estreturn=@EstReturn
WHERE     (TaskTypeID = 1 and prioritylevelid is null and estreturn is null)
