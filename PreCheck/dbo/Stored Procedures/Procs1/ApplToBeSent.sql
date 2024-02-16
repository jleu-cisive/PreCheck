-- =============================================
-- Date: April 22, 2005
-- Author: Steve Krenek
-- =============================================
--Select those Appls that have been finaled, but not sent
-- =============================================
CREATE  PROCEDURE ApplToBeSent
AS
SET NOCOUNT ON
--new query to catch appls stranded when switch client to AutoReportDelivery
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator, A.ApDate, A.Last, A.First, A.Middle, C.Name AS Client_Name 	FROM Appl A
   JOIN Client C ON A.Clno = C.Clno
  WHERE ApStatus in ('F') and IsAutoSent=0 
       and IsAutoPrinted=1 and not exists (SELECT * FROM BackgroundReports..BackgroundReport WHERE apno = a.apno)     --wait until auto processing has handled it -- will mark as printed for both Auto and manual
ORDER BY A.ApDate
--original query 
--SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator, A.ApDate, A.Last, A.First, A.Middle, C.Name AS Client_Name FROM Appl A
--JOIN Client C ON A.Clno = C.Clno
--WHERE ApStatus ='F' and IsAutoSent=0 and AutoReportDelivery = 0
----ORDER BY A.Apno
--ORDER BY A.ApDate