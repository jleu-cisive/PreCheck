


CREATE VIEW [dbo].[vwAdverseHistory]
AS
SELECT 
	[AdverseActionID],
	[APNO],
	[Hospital_CLNO],
	CurrentStatus = [StatusID],
	DateAdverseStarted = (SELECT TOP 1 Date FROM [dbo].[AdverseActionHistory] ah WITH (NOLOCK) INNER JOIN dbo.refAdverseStatus s WITH (NOLOCK) ON  ah.StatusID=s.refAdverseStatusID AND s.statusGroup='AdverseAction'
		WHERE ah.AdverseActionId = AA.AdverseActionId ORDER BY [Date] ASC),
	DateCurrentStatus = (SELECT TOP 1 Date FROM [dbo].[AdverseActionHistory] ah WITH (NOLOCK) INNER JOIN dbo.refAdverseStatus s WITH (NOLOCK) ON  ah.StatusID=s.refAdverseStatusID AND s.statusGroup='AdverseAction'
		WHERE ah.AdverseActionId = AA.AdverseActionId ORDER BY [Date] DESC),
	StatusDescription = L.[Status]
	,aa.ApplicantEmail,
	aa.Name,
	aa.ClientEmail,
	aa.Address1,
	aa.Address2,
	aa.City,
	aa.State,
	aa.Zip
FROM [dbo].[AdverseAction] AA WITH (NOLOCK)
INNER JOIN [dbo].[refAdverseStatus] l WITH (NOLOCK)
	ON AA.[StatusID]=L.refAdverseStatusID
	AND l.statusGroup='AdverseAction'



