

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetNotificationEmail]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


Select a.APNO,a.clno,c.Name--,U.EmailAddress
from Appl a inner join client c on a.clno = c.clno
inner Join ClientConfiguration cc on c.clno = cc.clno
--inner join Users U on c.cam = U.UserID
where a.inuse = 'Cams_E' and
ConfigurationKey = 'EScreen_DrugScreening' and cc.Value ='True'




    
END


