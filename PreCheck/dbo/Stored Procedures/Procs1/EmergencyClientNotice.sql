CREATE PROCEDURE EmergencyClientNotice AS


-- Created for Hurricanes and Emergency Precheck Closures - JS - Santosh(9/21/2005)

SELECT     distinct  'shrek' AS EmailServer,dbo.Client.CLNO, dbo.Client.Name, dbo.ClientContacts.Title, dbo.ClientContacts.FirstName, 
                      dbo.ClientContacts.MiddleName, dbo.ClientContacts.LastName, dbo.ClientContacts.Phone,dbo.ClientContacts.Ext, dbo.ClientContacts.Email as Emailto, 
                      dbo.refDeliveryMethod.DeliveryMethod, dbo.Client.Fax
FROM         dbo.Client INNER JOIN
                      dbo.ClientContacts ON dbo.Client.CLNO = dbo.ClientContacts.CLNO INNER JOIN
                      dbo.refContactType ON dbo.ClientContacts.ContactTypeID = dbo.refContactType.ContactTypeID INNER JOIN
                      dbo.refDeliveryMethod ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID
WHERE      (dbo.Client.DeliveryMethodID IN (2, 15, 17, 20, 22, 23, 24)) and dbo.ClientContacts.email is not null