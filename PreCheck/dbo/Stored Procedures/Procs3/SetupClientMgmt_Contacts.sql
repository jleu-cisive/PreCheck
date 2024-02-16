
CREATE PROCEDURE SetupClientMgmt_Contacts AS

Update ClientContacts Set CLNO = (SELECT a.ClientNumber from tblClient a
	where a.ClientID = ClientContacts.ClientID)

