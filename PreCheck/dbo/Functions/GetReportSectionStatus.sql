-- =============================================
-- Author:		Dongmei He
-- Create date: 04/06/2022
-- Description:	To return all the section statuses of a report/APNO.
-- SELECT * from [dbo].[GetReportSectionStatus] (322467)  
-- =============================================
CREATE FUNCTION [dbo].[GetReportSectionStatus] 
(	
	-- Add the parameters for the function here
	@ApplicationNumber	INT
)
RETURNS  @Result TABLE(ApplSectionID INT, Section Varchar(50), SectStat varchar(1), SectSubStatusID INT)
AS
BEGIN

	;WITH cte_empl
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  E.SectStat,
					  E.SectSubStatusID
			    FROM [dbo].Appl (nolock) a
			   INNER JOIN EMPL E ON a.APNO=e.Apno
			   INNER JOIN [dbo].ApplSections SA ON SA.Section='EMPL'
			   WHERE A.APNO=@ApplicationNumber
			   AND E.IsHidden=0 AND E.IsOnReport=1
		),
		cte_education
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  E.SectStat,
					  E.SectSubStatusID
			   FROM [dbo].Appl a
			   INNER JOIN [dbo].Educat E ON a.APNO=e.Apno
			   INNER JOIN [dbo].ApplSections SA ON SA.Section='EDUCAT'
			   WHERE A.APNO=@ApplicationNumber
			   AND E.IsHidden=0 AND E.IsOnReport=1
		),
		cte_proflic
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  pl.SectStat,
					  pl.SectSubStatusID
			   FROM [dbo].Appl a
			   INNER JOIN [dbo].ProfLic pl ON a.APNO=pl.Apno
			   INNER JOIN [dbo].ApplSections SA ON SA.Section='ProfLic'
			   WHERE A.APNO=@ApplicationNumber
			   AND pl.IsHidden = 0 AND pl.IsOnReport = 1 
		),
		cte_persref
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  pr.SectStat,
					  pr.SectSubStatusID
			   FROM [dbo].Appl a
			   INNER JOIN [dbo].PersRef pr ON a.APNO=pr.Apno
			   INNER JOIN [dbo].ApplSections SA ON SA.Section='PersRef'
			   WHERE A.APNO=@ApplicationNumber
			   AND pr.IsHidden = 0 AND pr.IsOnReport = 1 
		),
		cte_crim
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  C.Clear,
					  null as SectSubStatusID
			   FROM [dbo].Appl a
			   INNER JOIN [dbo].Crim C ON a.APNO=C.Apno
			   INNER JOIN [dbo].ApplSections SA ON SA.Section='Crim'
			   WHERE A.APNO=@ApplicationNumber
			   AND C.IsHidden=0 
		),
		cte_dl
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  D.SectStat,
					  null as SectSubStatusID
			   FROM [dbo].Appl a
			   INNER JOIN [dbo].DL D ON a.APNO=D.Apno
			   INNER JOIN [dbo].ApplSections SA ON SA.Section='DL'
			   WHERE A.APNO=@ApplicationNumber
		),
		cte_credit
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  C.SectStat,
					  null as SectSubStatusID
			   FROM [dbo].Appl a
			   INNER JOIN [dbo].Credit c ON a.APNO=c.Apno
			         AND c.RepType = 'C'
			   INNER JOIN [dbo].ApplSections SA ON SA.Section='Credit'
			   WHERE A.APNO=@ApplicationNumber
		),
		cte_pid
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  C.SectStat,
					  null as SectSubStatusID
			   FROM [dbo].Appl a
			   INNER JOIN [dbo].Credit c ON a.APNO=c.Apno
			          AND c.RepType = 'S'
			   INNER JOIN [dbo].ApplSections SA ON SA.Section='PositiveID'
			   WHERE A.APNO=@ApplicationNumber
		),
		cte_medinteg
		AS
		(
			   SELECT   
					  SA.ApplSectionID,
					  SA.Section AS ApplSection,
					  mi.SectStat,
					  null as SectSubStatusID
			   FROM [dbo].Appl a
			   INNER JOIN [dbo].MedInteg mi ON a.APNO=mi.Apno
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
		SELECT * FROM cte_pid
		UNION ALL
		SELECT * FROM cte_medinteg

    return
end   
