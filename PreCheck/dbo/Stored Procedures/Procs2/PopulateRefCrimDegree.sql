-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PopulateRefCrimDegree]
AS
BEGIN
select refCrimDegree, description
from refCrimDegree
where IsActive = 1
order by DisplayOrder
END
