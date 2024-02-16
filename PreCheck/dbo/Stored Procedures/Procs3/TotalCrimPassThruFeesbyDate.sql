-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TotalCrimPassThruFeesbyDate]
	
@StartDate datetime,
@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



select c.clno,c.name,i.* from invdetail i with (nolock) inner join appl a  with (nolock) on i.apno = a.apno
inner join client c  with (nolock) on c.clno = a.clno 
where  i.createdate >= @StartDate and i.createdate < @EndDate and 
(i.description like '%service charge%' --or i.description like '%Criminal Search%'
)
END
