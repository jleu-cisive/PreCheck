CREATE VIEW vwQReportUserMap
AS
SELECT
	M.QReportId,
	M.UserID,
	U.EmailAddress
	from
	dbo.QReportUserMap M
	LEFT OUTER JOIN USERS U ON M.UserId = u.UserID
WHERE M.UserID IS NOT NULL AND U.EmailAddress IS NOT NULL
	