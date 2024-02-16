CREATE PROCEDURE Service_TestFinalReport AS

-- JS Testing AutoReport Service 11/30/2005
SELECT     dbo.Appl.APNO, dbo.Appl.ApStatus, appl.last,appl.first,appl.middle,dbo.Appl.CLNO, ISNULL(dbo.Users.Name, '') AS AcctMgr, dbo.refDeliveryMethod.DeliveryMethod, dbo.Appl.Attn, 
                      dbo.Client.Fax, dbo.Client.AutoReportDelivery, dbo.Users.EmailAddress,appl.isautoprinted,appl.autoprinteddate,appl.isautosent,appl.autosentdate
FROM         dbo.Appl WITH (NOLOCK) INNER JOIN
                      dbo.Client WITH (NOLOCK) ON dbo.Appl.CLNO = dbo.Client.CLNO INNER JOIN
                      dbo.refDeliveryMethod ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID LEFT OUTER JOIN
                      dbo.Users ON dbo.Appl.UserID = dbo.Users.UserID
WHERE    appl.apno = '582066'