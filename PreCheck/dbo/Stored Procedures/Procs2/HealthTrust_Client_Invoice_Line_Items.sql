-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[HealthTrust_Client_Invoice_Line_Items]  
	@CLNO int,
 @StartDate datetime,
@Enddate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



select a.clno as ClientID,c.name as ClientName,c.addr1 as Address,c.city,c.state, i.* from invdetail i with (nolock) inner join appl a with (nolock) 
on i.apno = a.apno
inner join Client c on a.CLNO = c.CLNO
where (a.clno = @CLNO or @CLNO = 0)
and
a.clno in (select clno from clientgroup where groupcode = 0)
and
createdate >= @StartDate and
createdate < @EndDate

order by a.clno

END
