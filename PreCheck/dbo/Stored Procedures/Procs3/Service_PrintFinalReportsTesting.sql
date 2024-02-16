
CREATE PROCEDURE [dbo].[Service_PrintFinalReportsTesting] AS
---************* Updated for Sending Reports Only *********************-------



SELECT     dbo.Appl.APNO, dbo.Appl.ApStatus, appl.last,appl.first,appl.middle,dbo.Appl.CLNO, ISNULL(dbo.Users.Name, '') AS AcctMgr, dbo.refDeliveryMethod.DeliveryMethod, dbo.Appl.Attn, 
                      dbo.Client.Fax, dbo.Client.AutoReportDelivery, dbo.Users.EmailAddress,appl.isautoprinted,appl.autoprinteddate,appl.isautosent,appl.autosentdate
FROM         dbo.Appl INNER JOIN dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO INNER JOIN
                      dbo.refDeliveryMethod ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID LEFT OUTER JOIN
                      dbo.Users ON dbo.Appl.UserID = dbo.Users.UserID
WHERE     (dbo.Appl.APNO = 830150)
