-- =============================================
-- Author:		Humera Ahmed
-- Create date: 07/10/2020
-- Description:	To return all the CLEAR sections of a report/APNO.
-- SELECT * from [dbo].[GetReportSections] (51111111)  (5213684) (5203902)--(5207329)
-- =============================================
CREATE FUNCTION [dbo].[GetReportSections] 
(	
	-- Add the parameters for the function here
	@ApplicationNumber	INT
)
RETURNS  @Result TABLE(ApplSectionID INT, Section varchar(50), SectionKeyID INT, IsClear bit)
AS
BEGIN

	;WITH cte_empl
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section,
					  e.EmplID,
					  S.IsClear
			   FROM Appl a
			   INNER JOIN EMPL E ON a.APNO=e.Apno
			   INNER join SectStat S ON E.SECTStat = S.code 
			   INNER JOIN ApplSections SA ON SA.Section='EMPL'
			   WHERE A.APNO=@ApplicationNumber
			   AND E.IsHidden=0 AND E.IsOnReport=1
		),
		cte_education
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section,
					  e.EducatID,
					  S.IsClear
			   FROM Appl a
			   INNER JOIN Educat E ON a.APNO=e.Apno
			   INNER join SectStat S ON E.SECTStat = s.code 
			   INNER JOIN ApplSections SA ON SA.Section='EDUCAT'
			   WHERE A.APNO=@ApplicationNumber
			   AND E.IsHidden=0 AND E.IsOnReport=1
		),
		cte_proflic
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section,
					  pl.ProfLicID,
					  S.IsClear
			   FROM Appl a
			   INNER JOIN ProfLic pl ON a.APNO=pl.Apno
			   INNER join SectStat S ON pl.SECTStat = s.code 
			   INNER JOIN ApplSections SA ON SA.Section='ProfLic'
			   WHERE A.APNO=@ApplicationNumber
			   AND pl.IsHidden = 0 AND pl.IsOnReport = 1 
		),
		cte_persref
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section,
					  pr.PersRefID,
					  S.IsClear
			   FROM Appl a
			   INNER JOIN PersRef pr ON a.APNO=pr.Apno
			   INNER join SectStat S ON pr.SECTStat = s.code 
			   INNER JOIN ApplSections SA ON SA.Section='PersRef'
			   WHERE A.APNO=@ApplicationNumber
			   AND pr.IsHidden = 0 AND pr.IsOnReport = 1 
		),
		cte_crim
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section,
					  C.CrimID,
					  S.IsClear
			   FROM Appl a
			   INNER JOIN Crim C ON a.APNO=C.Apno
			   INNER join CrimSectStat S ON C.Clear = S.crimsect
			   INNER JOIN ApplSections SA ON SA.Section='Crim'
			   WHERE A.APNO=@ApplicationNumber
			   AND C.IsHidden=0 
		),
		cte_dl
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section,
					  D.APNO,
					  S.IsClear
			   FROM Appl a
			   INNER JOIN DL D ON a.APNO=D.Apno
			   INNER join SectStat S ON D.SECTStat = s.code
			   INNER JOIN ApplSections SA ON SA.Section='DL'
			   WHERE A.APNO=@ApplicationNumber
		),
		cte_credit
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section,
					  c.APNO,
					  S.IsClear
			   FROM Appl a
			   INNER JOIN dbo.Credit c ON a.APNO=c.Apno
			   INNER join SectStat S ON c.SECTStat = s.code
			   INNER JOIN ApplSections SA ON SA.Section='Credit'
			   WHERE A.APNO=@ApplicationNumber
		),
		cte_medinteg
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section,
					  mi.APNO,
					  S.IsClear
			   FROM Appl a
			   INNER JOIN dbo.MedInteg mi ON a.APNO=mi.Apno
			   INNER join SectStat S ON mi.SECTStat = s.code
			   INNER JOIN ApplSections SA ON SA.Section='MedInteg'
			   WHERE A.APNO=@ApplicationNumber
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