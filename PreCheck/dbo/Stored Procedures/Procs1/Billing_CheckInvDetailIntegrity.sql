


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_CheckInvDetailIntegrity]
	
AS
BEGIN
SELECT count(1) FROM Appl (NOLOCK)
 inner join InvDetail (NOLOCK) on Appl.APNO = InvDetail.APNO
 WHERE Appl.Billed = 0 AND InvDetail.Billed = 1


--SELECT Appl.Apno into #tmpAppl FROM Appl (NOLOCK)
-- inner join InvDetail (NOLOCK) on Appl.APNO = InvDetail.APNO
-- WHERE Appl.Billed = 0 AND InvDetail.Billed = 1
--
--
----Update the Appl.Billed=1 for all the above apno's
--Update Appl Set Billed =1 
--Where Apno in 
--(SELECT Apno FROM #tmpAppl)   
--
--
--SELECT Apno FROM #tmpAppl
--
--Drop table #tmpAppl 
          
END



