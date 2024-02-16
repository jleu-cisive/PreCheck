-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 02/20/2020
-- Description:	To return all the CLEAR sections of a report/APNO.
-- SELECT * from [dbo].[GetAdverseReportSections] (33,7519,'PreAdverse', '1/1/2021', '2/')
-- =============================================
CREATE FUNCTION [dbo].[GetAdverseReportSections] 
(	
	-- Add the parameters for the function here
	@AdverseActionStatusId INT = NULL,
	@ParentClientId		  INT,
	@RuleGroup			   VARCHAR(50),
	@AdverseStartDate		DATETIME = NULL,
	@AdverseEndDate			DATETIME = NULL
)
RETURNS  @Result TABLE(APNO INT, ApplSectionID INT, Section varchar(50), SectionKeyID INT, IsClear bit)
AS
BEGIN

	;WITH cte_empl
		AS
		(
			   SELECT
					   a.APNO,
					  SA.ApplSectionID,
					  SA.Section,
					  e.EmplID,
					  S.IsClear
			   FROM Appl a WITH(NOLOCK)
			   INNER JOIN dbo.vwClient cl WITH (NOLOCK) ON a.CLNO=cl.ClientId
			   INNER JOIN EMPL E WITH(NOLOCK) ON a.APNO=e.Apno
			   INNER join SectStat S WITH(NOLOCK) ON E.SECTStat = S.code 
			   INNER JOIN ApplSections SA WITH(NOLOCK) ON SA.Section='EMPL'
			   INNER JOIN dbo.vwAdverseHistory AH WITH(NOLOCK) ON A.APNO=AH.APNO
			   INNER JOIN Compliance.AdverseActionReason aar WITH (NOLOCK) ON AH.APNO=AAR.APNO 
			   WHERE 
			   aar.RuleGroup=@RuleGroup and AH.CurrentStatus=ISNULL(@AdverseActionStatusId, AH.CurrentStatus)
			   AND (cl.ParentId=@ParentClientId OR cl.ClientId=@ParentClientId)
			   AND E.IsHidden=0 AND E.IsOnReport=1
			   AND AH.DateAdverseStarted BETWEEN ISNULL(@AdverseStartDate, AH.DateAdverseStarted) 
			   AND ISNULL(@AdverseEndDate, CURRENT_TIMESTAMP)

		),
		cte_education
		AS
		(
			   SELECT   
					 ah.APNO,
					  SA.ApplSectionID,
					  SA.Section,
					  e.EducatID,
					  S.IsClear
			   FROM Appl a WITH(NOLOCK)
			   INNER JOIN dbo.vwClient cl WITH (NOLOCK) ON a.CLNO=cl.ClientId
			   INNER JOIN Educat E WITH(NOLOCK) ON a.APNO=e.Apno
			   INNER join SectStat S WITH(NOLOCK) ON E.SECTStat = s.code 
			   INNER JOIN ApplSections SA WITH(NOLOCK) ON SA.Section='EDUCAT'
			   INNER JOIN dbo.vwAdverseHistory AH WITH(NOLOCK) ON A.APNO=AH.APNO
				INNER JOIN Compliance.AdverseActionReason aar WITH (NOLOCK) ON AH.APNO=AAR.APNO 
			   WHERE 
			   aar.RuleGroup=@RuleGroup and AH.CurrentStatus=ISNULL(@AdverseActionStatusId, AH.CurrentStatus)
			   AND (cl.ParentId=@ParentClientId OR cl.ClientId=@ParentClientId)
			   AND E.IsHidden=0 AND E.IsOnReport=1
			    AND AH.DateAdverseStarted BETWEEN ISNULL(@AdverseStartDate, AH.DateAdverseStarted) 
			   AND ISNULL(@AdverseEndDate, CURRENT_TIMESTAMP)
		),
		cte_proflic
		AS
		(
			   SELECT   
						a.apno,
					  SA.ApplSectionID,
					  SA.Section,
					  pl.ProfLicID,
					  S.IsClear
			   FROM Appl a WITH(NOLOCK)
			   INNER JOIN dbo.vwClient cl WITH (NOLOCK) ON a.CLNO=cl.ClientId
			   INNER JOIN ProfLic pl WITH(NOLOCK) ON a.APNO=pl.Apno
			   INNER join SectStat S WITH(NOLOCK) ON pl.SECTStat = s.code 
			   INNER JOIN ApplSections SA WITH(NOLOCK) ON SA.Section='ProfLic'
			   INNER JOIN dbo.vwAdverseHistory AH WITH(NOLOCK) ON A.APNO=AH.APNO
			   INNER JOIN Compliance.AdverseActionReason aar WITH (NOLOCK) ON AH.APNO=AAR.APNO 
			   WHERE 
			   aar.RuleGroup=@RuleGroup and AH.CurrentStatus=ISNULL(@AdverseActionStatusId, AH.CurrentStatus)
			   AND (cl.ParentId=@ParentClientId OR cl.ClientId=@ParentClientId)
			   AND pl.IsHidden = 0 AND pl.IsOnReport = 1 
			    AND AH.DateAdverseStarted BETWEEN ISNULL(@AdverseStartDate, AH.DateAdverseStarted) 
			   AND ISNULL(@AdverseEndDate, CURRENT_TIMESTAMP)
		),
		cte_persref
		AS
		(
			   SELECT   
			   a.apno,
					  SA.ApplSectionID,
					  SA.Section,
					  pr.PersRefID,
					  S.IsClear
			   FROM Appl a WITH(NOLOCK)
			   INNER JOIN dbo.vwClient cl WITH (NOLOCK) ON a.CLNO=cl.ClientId
			   INNER JOIN PersRef pr WITH(NOLOCK) ON a.APNO=pr.Apno
			   INNER join SectStat S WITH(NOLOCK) ON pr.SECTStat = s.code 
			   INNER JOIN ApplSections SA WITH(NOLOCK) ON SA.Section='PersRef'
			   INNER JOIN dbo.vwAdverseHistory AH WITH(NOLOCK) ON A.APNO=AH.APNO
			   INNER JOIN Compliance.AdverseActionReason aar WITH (NOLOCK) ON AH.APNO=AAR.APNO 
			   WHERE 
			   aar.RuleGroup=@RuleGroup and AH.CurrentStatus=ISNULL(@AdverseActionStatusId, AH.CurrentStatus)
			   AND (cl.ParentId=@ParentClientId OR cl.ClientId=@ParentClientId)
			   AND pr.IsHidden = 0 AND pr.IsOnReport = 1 
			    AND AH.DateAdverseStarted BETWEEN ISNULL(@AdverseStartDate, AH.DateAdverseStarted) 
			   AND ISNULL(@AdverseEndDate, CURRENT_TIMESTAMP)
		),
		cte_crim
		AS
		(
			   SELECT   
					a.apno,
					  SA.ApplSectionID,
					  SA.Section,
					  C.CrimID,
					  S.IsClear
			   FROM Appl a WITH(NOLOCK)
			   INNER JOIN dbo.vwClient cl WITH (NOLOCK) ON a.CLNO=cl.ClientId
			   INNER JOIN Crim C WITH(NOLOCK) ON a.APNO=C.Apno
			   INNER join CrimSectStat S WITH(NOLOCK) ON C.Clear = S.crimsect
			   INNER JOIN ApplSections SA WITH(NOLOCK) ON SA.Section='Crim'
			   INNER JOIN dbo.vwAdverseHistory AH WITH(NOLOCK) ON A.APNO=AH.APNO
			   INNER JOIN Compliance.AdverseActionReason aar WITH (NOLOCK) ON AH.APNO=AAR.APNO 
			   WHERE 
			   aar.RuleGroup=@RuleGroup and AH.CurrentStatus=ISNULL(@AdverseActionStatusId, AH.CurrentStatus)
			   AND (cl.ParentId=@ParentClientId OR cl.ClientId=@ParentClientId) 
			   AND C.IsHidden=0 
			    AND AH.DateAdverseStarted BETWEEN ISNULL(@AdverseStartDate, AH.DateAdverseStarted) 
			   AND ISNULL(@AdverseEndDate,CURRENT_TIMESTAMP)
		),
		cte_dl
		AS
		(
			   SELECT   
					A.APNO,
					  SA.ApplSectionID,
					  SA.Section,
					  DLID = D.APNO,
					  S.IsClear
			   FROM Appl a WITH(NOLOCK)
			   INNER JOIN dbo.vwClient cl WITH (NOLOCK) ON a.CLNO=cl.ClientId
			   INNER JOIN DL D WITH(NOLOCK) ON a.APNO=D.Apno
			   INNER join SectStat S WITH(NOLOCK) ON D.SECTStat = s.code
			   INNER JOIN ApplSections SA WITH(NOLOCK) ON SA.Section='DL'
			   INNER JOIN dbo.vwAdverseHistory AH WITH(NOLOCK) ON A.APNO=AH.APNO
			   INNER JOIN Compliance.AdverseActionReason aar WITH (NOLOCK) ON AH.APNO=AAR.APNO 
			   WHERE 
			   aar.RuleGroup=@RuleGroup and AH.CurrentStatus=ISNULL(@AdverseActionStatusId, AH.CurrentStatus)
			   AND (cl.ParentId=@ParentClientId OR cl.ClientId=@ParentClientId)
			    AND AH.DateAdverseStarted BETWEEN ISNULL(@AdverseStartDate, AH.DateAdverseStarted) 
			   AND ISNULL(@AdverseEndDate, CURRENT_TIMESTAMP)
		),
		cte_credit
		AS
		(
			   SELECT   
				a.apno,
					  SA.ApplSectionID,
					  SA.Section,
					  CreditId = c.APNO,
					  S.IsClear
			   FROM Appl a WITH(NOLOCK)
			   INNER JOIN dbo.vwClient cl WITH (NOLOCK) ON a.CLNO=cl.ClientId
			   INNER JOIN dbo.Credit c WITH(NOLOCK) ON a.APNO=c.Apno
			   INNER join SectStat S WITH(NOLOCK) ON c.SECTStat = s.code
			   INNER JOIN ApplSections SA WITH(NOLOCK) ON SA.Section='Credit'
			   INNER JOIN dbo.vwAdverseHistory AH WITH(NOLOCK) ON A.APNO=AH.APNO
			   INNER JOIN Compliance.AdverseActionReason aar WITH (NOLOCK) ON AH.APNO=AAR.APNO 
			   WHERE 
			   aar.RuleGroup=@RuleGroup and AH.CurrentStatus=ISNULL(@AdverseActionStatusId, AH.CurrentStatus)
			   AND (cl.ParentId=@ParentClientId OR cl.ClientId=@ParentClientId)
			    AND AH.DateAdverseStarted BETWEEN ISNULL(@AdverseStartDate, AH.DateAdverseStarted) 
			   AND ISNULL(@AdverseEndDate, CURRENT_TIMESTAMP)
		),
		cte_medinteg
		AS
		(
			   SELECT   
			   a.apno,
					  SA.ApplSectionID,
					  SA.Section,
					  MedId = mi.APNO,
					  S.IsClear
			   FROM Appl a WITH(NOLOCK)
			   INNER JOIN dbo.vwClient cl WITH (NOLOCK) ON a.CLNO=cl.ClientId
			   INNER JOIN dbo.MedInteg mi WITH(NOLOCK) ON a.APNO=mi.Apno
			   INNER join SectStat S WITH(NOLOCK) ON mi.SECTStat = s.code
			   INNER JOIN ApplSections SA WITH(NOLOCK) ON SA.Section='MedInteg'
			  INNER JOIN dbo.vwAdverseHistory AH WITH(NOLOCK) ON A.APNO=AH.APNO
			  INNER JOIN Compliance.AdverseActionReason aar WITH (NOLOCK) ON AH.APNO=AAR.APNO 
			   WHERE 
			   aar.RuleGroup=@RuleGroup and AH.CurrentStatus=ISNULL(@AdverseActionStatusId, AH.CurrentStatus)
			   AND (cl.ParentId=@ParentClientId OR cl.ClientId=@ParentClientId)
			    AND AH.DateAdverseStarted BETWEEN ISNULL(@AdverseStartDate, AH.DateAdverseStarted) 
			   AND ISNULL(@AdverseEndDate, CURRENT_TIMESTAMP)
		)

		INSERT INTO @Result

		SELECT * FROM cte_empl
		UNION ALL 
		SELECT * FROM cte_education
		UNION ALL
		SELECT * FROM cte_proflic
		UNION ALL
		SELECT * FROM cte_persref
		UNION ALL
		SELECT * FROM cte_crim
		UNION ALL 
		SELECT * FROM cte_dl
		UNION ALL
		SELECT * FROM cte_credit
		UNION ALL
		SELECT * FROM cte_medinteg

    return
end   
