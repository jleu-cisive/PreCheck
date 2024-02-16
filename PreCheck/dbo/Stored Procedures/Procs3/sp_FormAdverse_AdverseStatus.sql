

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_FormAdverse_AdverseStatus]
@statusgroup Varchar(50) = 'AdverseAction'
As
SELECT refAdverseStatusID, Status, IsInactive 
FROM dbo.refAdverseStatus 
where statusGroup = @statusgroup

