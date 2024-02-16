

CREATE VIEW [Security].[vwProducts]
AS
SELECT        ProductId, ProductNumber, ProductName, sc.Password,sc.SubscriberEmail,sc.LastPasswordResetDate
FROM            SecureBridge.dbo.Product p inner join SecureBridge.dbo.SubscriberCredential sc on p.ProductId= sc.SubscriberId
where p.IsActive=1 and sc.IsActive = 1 
