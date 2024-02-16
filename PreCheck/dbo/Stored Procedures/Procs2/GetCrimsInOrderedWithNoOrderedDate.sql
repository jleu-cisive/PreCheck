-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetCrimsInOrderedWithNoOrderedDate]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
	
AS
BEGIN

if @StartDate = '1/1/1900'
begin
set @StartDate = '01/01/1976'
end

if @EndDate = '1/1/1900'
begin
set @EndDate = '01/01/2090'
end

select a.apno,a.apdate, a.apstatus,a.last,a.first,c.county,
c.deliverymethod
from appl a with (nolock)
inner join crim c with (nolock) on a.apno = c.apno
where c.ishidden = 0 and c.clear = 'O' and c.IrisOrdered is null
and    ((Convert(date, a.apdate)>= CONVERT(date, @StartDate)) 
  AND (Convert(date, a.apdate) <= CONVERT(date, @EndDate)))
order by crimid asc
END
