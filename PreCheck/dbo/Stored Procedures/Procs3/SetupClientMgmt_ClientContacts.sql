CREATE PROCEDURE SetupClientMgmt_ClientContacts AS

Update ClientContacts Set ContactTypeID=a.ContactTypeID FROM ClientContacts c
	JOIN refContactType a ON a.ContactType=c.ContactType