
CREATE PROCEDURE SetupClientMgmt_Clean_tbls AS

DELETE tblSales FROM tblSales ts
INNER JOIN tblClient tc ON tc.ClientID=ts.ClientID
WHERE (tc.ClientNumber is null) or (tc.ClientNumber=0)

DELETE tblRequirements FROM tblRequirements ts
INNER JOIN tblClient tc ON tc.ClientID=ts.ClientID
WHERE (tc.ClientNumber is null) or (tc.ClientNumber=0)

DELETE tblBilling FROM tblBilling ts
INNER JOIN tblClient tc ON tc.ClientID=ts.ClientID
WHERE (tc.ClientNumber is null) or (tc.ClientNumber=0)

DELETE tblNotes FROM tblNotes ts
INNER JOIN tblClient tc ON tc.ClientID=ts.ClientID
WHERE (tc.ClientNumber is null) or (tc.ClientNumber=0)

DELETE tblContacts FROM tblContacts ts
INNER JOIN tblClient tc ON tc.ClientID=ts.ClientID
WHERE (tc.ClientNumber is null) or (tc.ClientNumber=0)

DELETE tblClient 
WHERE (ClientNumber is null) or (ClientNumber=0)

