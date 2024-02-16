-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetEmail]

AS
BEGIN
Create table #temptable
(
email varchar(2000)
)

Insert into #temptable (email)
(
SELECT SUBSTRING(Priv_Notes, (SELECT CHARINDEX( 'EMAIL:', Priv_Notes) AS comma_position from Appl AA where AA.CLNO =6893 AND A.APNO = AA.APNO )+7,35)
AS email from Appl A where CLNO =6893
)




Select * from #temptable

DROP TABLE #temptable
END

