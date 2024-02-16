



 CREATE VIEW [dbo].[vwGetNextAvailableUsers]
 AS
 SELECT DISTINCT
	u.UserID, 
	u.Name, 
	--ISNULL(s.IsActive,1) AS IsActive,
	--refRoleID
	CASE WHEN ISNULL(s.refRoleID,0) = 12 THEN 0
		 ELSE 1
	END UnAvailableRole
 FROM Users AS u
 LEFT JOIN UserRolesBySection AS s ON u.UserID = s.UserID AND s.refRoleID = 12 AND s.IsActive = 1
 WHERE u.empl = 1
    AND u.UserID NOT IN ('overseas','thorngre','refpro')


