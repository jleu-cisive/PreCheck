

/******************************
Author : Gaurav Bangia
Date: 3/16/2021
******************************/

CREATE VIEW [dbo].[vwClientContactUser]
WITH SCHEMABINDING
AS

SELECT 
CTE.ContactID,
CLNO,
CTE.PrimaryContact,
CTE.ContactType,
CTE.ReportFlag,
CTE.Title,
CTE.FirstName,
CTE.MiddleName,
CTE.LastName,
CTE.Phone
Ext,
CTE.Email,
CTE.tmpPhone,
CTE.username,
CTE.UserPassword,
CTE.WOLockout,
CTE.GetsReportEmail,
CTE.GetsReport,
CTE.IsActive,
CTE.ClientRoleID
FROM 
dbo.ClientContacts CTE
INNER JOIN
(
	SELECT
	OldContactId= MIN(CC.ContactID)
	FROM dbo.ClientContacts CC
	GROUP BY CC.Email, CC.CLNO
) L 
ON CTE.ContactID=L.OldContactId
WHERE CTE.Email IS NOT NULL AND clno IS NOT NULL

