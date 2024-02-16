
-- Purpose to put correct index value in Clientnotes for 

-- Created 7/18/2003 by Steve Krenek


CREATE PROCEDURE SetupClientMgmt_Notes AS

Update ClientNotes Set CLNO = (SELECT a.ClientNumber from tblClient a
	where a.ClientID = ClientNotes.ClientID)
