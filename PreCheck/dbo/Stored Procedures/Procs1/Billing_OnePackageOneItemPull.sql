
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_OnePackageOneItemPull]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT id.apno,id.Description,id.Amount,c.clno,c.Name As ClientName,a.ApDate,a.CompDate,a.ReopenDate,a.OrigCompDate
  FROM InvDetail id inner join Appl a on id.apno = a.apno inner join Client c on a.clno = c.clno
 WHERE id.Billed = 0 AND a.clno <> 3668 and ((SELECT Count(*) FROM InvDetail id2 WHERE id2.apno = id.apno) = 2) AND ((SELECT Count(*) FROM InvDetail id2 WHERE id2.apno = id.apno AND Description like '%Package%') = 1)order by id.apno,id.createDate

END

