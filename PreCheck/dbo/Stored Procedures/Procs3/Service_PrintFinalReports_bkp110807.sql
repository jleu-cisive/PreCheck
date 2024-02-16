CREATE PROCEDURE [dbo].[Service_PrintFinalReports_bkp110807] AS
---************* Updated for Sending Reports Only *********************-------
Update Appl
set appl.inuse = 'Sending'
from Appl A inner join Client C
On (A.CLNO = C.CLNO)
WHERE   A.ApStatus = 'f' --OR  A.ApStatus = 'W')3/15/07 removed W status
 AND (A.IsAutoSent = 0) AND (A.InUse IS NULL) AND (C.AutoReportDelivery = '1') AND 
                      (A.IsAutoPrinted = '1') 



SELECT     dbo.Appl.APNO, dbo.Appl.ApStatus, appl.last,appl.first,appl.middle,dbo.Appl.CLNO, ISNULL(dbo.Users.Name, '') AS AcctMgr, dbo.refDeliveryMethod.DeliveryMethod, dbo.Appl.Attn, 
                      dbo.Client.Fax, dbo.Client.AutoReportDelivery, dbo.Users.EmailAddress,appl.isautoprinted,appl.autoprinteddate,appl.isautosent,appl.autosentdate
FROM         dbo.Appl INNER JOIN dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO INNER JOIN
                      dbo.refDeliveryMethod ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID LEFT OUTER JOIN
                      dbo.Users ON dbo.Appl.UserID = dbo.Users.UserID
WHERE     (dbo.Appl.InUse = 'Sending')
