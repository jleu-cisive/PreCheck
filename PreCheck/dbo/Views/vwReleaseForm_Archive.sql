
CREATE VIEW vwReleaseForm_Archive AS
SELECT * FROM PreCheck_MainArchive.dbo.ReleaseForm_Archive WITH (NOLOCK)
UNION ALL
SELECT * FROM PreCheck.dbo.ReleaseForm WITH (NOLOCK)

--SELECT COUNT(*) FROM vwReleaseForm_Archive -- 1342408