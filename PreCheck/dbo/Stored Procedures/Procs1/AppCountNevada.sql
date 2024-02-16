
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	gets the app count for State of NV , as used to pay MCSS on NO of apps, Make sure both relults count is same
-- =============================================
CREATE PROCEDURE [dbo].[AppCountNevada] 
@StartDate varchar(15),
@enddate varchar(15)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select Apno, a.EnteredVia, ApStatus,ApDate,a.CreatedDate, a.Clno, Name

from Appl a inner join client c on a.clno = c.clno 

inner Join clientconfiguration cc on  c.clno = cc.clno 

where cc.configurationkey = 'redirect_nevada' and cc.value = 'True' 

and a.CreatedDate >= @StartDate and a.CreatedDate < @enddate

order by APNO

 

/* 

select Apno, a.EnteredVia, ApStatus,ApDate,a.CreatedDate, a.Clno, Name

from Appl a inner join client c on a.clno = c.clno 

where c.state = 'NV' 

and a.CreatedDate >= @StartDate and a.CreatedDate < @enddate

order by APNO
*/
END

