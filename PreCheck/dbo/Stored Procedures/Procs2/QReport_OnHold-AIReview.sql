
-- =============================================
-- Author:		Humera Ahmed
-- Create date: 8/21/2019
-- Description:	QReport that will show only reports that have a component in the "OnHold-AIReview" status in the Used Section.
-- EXEC [QReport_OnHold-AIReview] '1/1/2018','8/22/2019'
-- Modified by Amy liu for HDT7298: add a column for "Investigator" to the QReport.
--Modified by Vairavan A on 04/17/2023 for Ticket no 91051: Add a column for CAM on OnHold-AI-Review Qreport
-- =============================================
CREATE PROCEDURE [dbo].[QReport_OnHold-AIReview]
	@StartDate datetime, 
	@EndDate datetime
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
			[Report Number]
			, [Created Date]
			, [Original Completed Date]
			, [Report Status]
			, [Elapsed/TAT]
			, [CAM]
			, [Client ID]
			, [Client Name]
			, [First Name]
			, [Last Name]
			, [Component]
			, [Component Detail]
			, [Component Status]
			,Investigator
		FROM
		( 
			(SELECT 
				 a.apno [Report Number], a.Investigator
				, a.ApDate [Created Date]
				, a.OrigCompDate [Original Completed Date]
				, a.ApStatus [Report Status]
				, [dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [Elapsed/TAT]
				--, a.CAM [CAM]--code commented for ticket no - 91051
				, C.CAM [CAM]--code added for ticket no - 91051
				, a.CLNO [Client ID]
				, c.Name [Client Name]
				, a.First [First Name]
				, a.Last [Last Name]
				, 'Employment' [Component]
				, e.Employer [Component Detail]
				, ss.Description [Component Status]
				 From appl(NOLOCK)a
				 INNER JOIN client c ON a.CLNO = c.CLNO
				inner join empl(NOLOCK) e on a.APNO = e.Apno
				INNER JOIN SectStat ss ON e.SectStat = ss.Code
				where 
				(convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
				AND e.IsHidden = 0
				AND e.SectStat = 'H'
				AND a.clno NOT IN (2135,3468)
			) 

			UNION
			 
			(SELECT 
				 a.apno [Report Number], a.Investigator
				, a.ApDate [Created Date]
				, a.OrigCompDate [Original Completed Date]
				, a.ApStatus [Report Status]
				, [dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [Elapsed/TAT]
				--, a.CAM [CAM]--code commented for ticket no - 91051
				, C.CAM [CAM]--code added for ticket no - 91051
				, a.CLNO [Client ID]
				, c.Name [Client Name]
				, a.First [First Name]
				, a.Last [Last Name]
				, 'Education' [Component]
				, ed.School [Component Detail]
				, ss.Description [Component Status]
				 From appl(NOLOCK)a
				 INNER JOIN client c ON a.CLNO = c.CLNO
				inner join educat(NOLOCK) ed on a.APNO = ed.Apno
				INNER JOIN SectStat ss ON ed.SectStat = ss.Code
				where 
				(convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
				AND ed.IsHidden = 0
				AND ed.SectStat = 'H'
				AND a.clno NOT IN (2135,3468)
			)

			UNION
			 
			(SELECT 
				 a.apno [Report Number], a.Investigator
				, a.ApDate [Created Date]
				, a.OrigCompDate [Original Completed Date]
				, a.ApStatus [Report Status]
				, [dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [Elapsed/TAT]
				--, a.CAM [CAM]--code commented for ticket no - 91051
				, C.CAM [CAM]--code added for ticket no - 91051
				, a.CLNO [Client ID]
				, c.Name [Client Name]
				, a.First [First Name]
				, a.Last [Last Name]
				, 'License' [Component]
				, pl.Lic_Type [Component Detail]
				, ss.Description [Component Status]
				 From appl(NOLOCK)a
				 INNER JOIN client c ON a.CLNO = c.CLNO
				inner join ProfLic(NOLOCK) pl on a.APNO = pl.Apno
				INNER JOIN SectStat ss ON pl.SectStat = ss.Code
				where 
				(convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
				AND pl.IsHidden = 0
				AND pl.SectStat = 'H'
				AND a.clno NOT IN (2135,3468)
			)

			UNION
			 
			(SELECT 
				 a.apno [Report Number], a.Investigator
				, a.ApDate [Created Date]
				, a.OrigCompDate [Original Completed Date]
				, a.ApStatus [Report Status]
				, [dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [Elapsed/TAT]
				--, a.CAM [CAM]--code commented for ticket no - 91051
				, C.CAM [CAM]--code added for ticket no - 91051
				, a.CLNO [Client ID]
				, c.Name [Client Name]
				, a.First [First Name]
				, a.Last [Last Name]
				, 'Public Records' [Component]
				, cr.County [Component Detail]
				, ss.Description [Component Status]
				 From appl(NOLOCK)a
				 INNER JOIN client c ON a.CLNO = c.CLNO
				inner JOIN Crim(NOLOCK) cr on a.APNO = cr.Apno
				INNER JOIN SectStat ss ON cr.clear = ss.Code
				where 
				(convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
				AND cr.IsHidden = 0
				AND cr.Clear = 'H'
				AND a.clno NOT IN (2135,3468)
			)

			UNION
			 
			(SELECT 
				 a.apno [Report Number], a.Investigator
				, a.ApDate [Created Date]
				, a.OrigCompDate [Original Completed Date]
				, a.ApStatus [Report Status]
				, [dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [Elapsed/TAT]
				--, a.CAM [CAM]--code commented for ticket no - 91051
				, C.CAM [CAM]--code added for ticket no - 91051
				, a.CLNO [Client ID]
				, c.Name [Client Name]
				, a.First [First Name]
				, a.Last [Last Name]
				, 'Crim' [Component]
				, cr.County [Component Detail]
				, ss.Description [Component Status]
				 From appl(NOLOCK)a
				 INNER JOIN client c ON a.CLNO = c.CLNO
				inner JOIN Crim(NOLOCK) cr on a.APNO = cr.Apno
				INNER JOIN SectStat ss ON cr.clear = ss.Code
				where 
				(convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
				AND cr.IsHidden = 0
				AND cr.Clear = 'H'
				AND a.clno NOT IN (2135,3468)
			)

			UNION
			 
			(SELECT 
				 a.apno [Report Number], a.Investigator
				, a.ApDate [Created Date]
				, a.OrigCompDate [Original Completed Date]
				, a.ApStatus [Report Status]
				, [dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [Elapsed/TAT]
				--, a.CAM [CAM]--code commented for ticket no - 91051
				, C.CAM [CAM]--code added for ticket no - 91051
				, a.CLNO [Client ID]
				, c.Name [Client Name]
				, a.First [First Name]
				, a.Last [Last Name]
				, 'Personal References' [Component]
				, pr.Name [Component Detail]
				, ss.Description [Component Status]
				 From appl(NOLOCK)a
				 INNER JOIN client c ON a.CLNO = c.CLNO
				inner JOIN PersRef (NOLOCK) pr on a.APNO = pr.Apno
				INNER JOIN SectStat ss ON pr.SectStat = ss.Code
				where 
				(convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
				AND pr.IsHidden = 0
				AND pr.SectStat = 'H'
				AND a.clno NOT IN (2135,3468)
			)
		) A
		ORDER BY A.Component
END

