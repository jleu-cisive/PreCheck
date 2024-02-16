-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/08/2017
-- Description:	QReport should show - Totals of Employment Needing a First Attempt for our Top Client Groups and their Aging.  First attempt needed can be determined 
--      by those in Web Status "Choose." First Column would have Days Aging, Second Column is HCA, third column is Tenet, fourth column is CHI, 
--      and fifth column is Universal Health Systems.  HCA data should be derived using affiliates HCA, and HCA - Parallon (aggregated), 
--      Tenet data should be derived using affiliates Tenet Healthcare and Tenet EWS,
--      CHI data should be derived using affiliates CHI - Independent and CHI - National, and Universal Health Systems should be derived using web parent CLNO 13126. 
-- Execution: EXEC [dbo].[Big4_Employment_Status_First_Attempts] '01/01/2017','09/22/2017'
-- =============================================
CREATE PROCEDURE [dbo].[Big4_Employment_Status_First_Attempts]
	@StartDate datetime,
	@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SectionTable TABLE 
	( 
		NumberOfDays nvarchar(2)
	) 

	insert into @SectionTable (NumberOfDays)values
	('7+'),('6'),('5'),('4'),('3'),('2'),('1'),('0')

    -- Insert statements for procedure here
	SELECT	a.Apno as ReportNumber, a.ApStatus, (case when E.DNC = 0 then 'No' else 'Yes' end) as DoNotContact,
			dbo.elapsedbusinessdays_2(a.ApDate, E.InvestigatorAssigned) as BusinessDays,
			a.ApDate as ReportCreatedDate, A.Investigator, E.InvestigatorAssigned as InvestigatorAssignedDate,
			E.Employer as EmployerName, C.Name as CLientName, rtrim(ltrim(Ws.Description)) as WebStatus,
			E.Web_Updated, MainDB.dbo.fnGetTimeZone(E.[ZipCode], E.[City], E.[State]) [TimeZone],
			RA.Affiliate, RA.AffiliateID, a.UserID CAM,Parent =CAST(c.WebOrderParentCLNO AS VARCHAR) + ' - ' + P.Name
	into #tempFirstAttempt
	FROM Empl AS E WITH(NOLOCK)
	INNER JOIN Appl AS a WITH(NOLOCK) on a.Apno = E.Apno
	INNER JOIN CLient AS C WITH(NOLOCK) on a.CLNO = C.CLNO
	INNER JOIN WebSectStat AS Ws WITH(NOLOCK) on Ws.code = E.web_status
	INNER JOIN refAffiliate AS ra WITH (NOLOCK) ON ra.AffiliateID = c.AffiliateID
	LEFT JOIN CLient AS P WITH(NOLOCK) on C.WebOrderParentCLNO = P.CLNO
	WHERE E.IsOnReport = 1 
	 AND E.SectStat IN('0','9')
	 AND E.WEB_STATUS IN (0, 92)
	 AND A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	 AND A.CLNO NOT IN (3468,2135)
	 AND RA.AffiliateID IN (4,5,10, 164,166,147,159,177)
	ORDER BY E.Investigator, a.ApStatus

	select a.NumberOfDays,b.Affiliate,b.Total 
	into #tempsecondattempt
	from @SectionTable a
	inner join (
	select (case when AffiliateID in (147,159) then 'CHI'
	             when AffiliateID in (4,5) then 'HCA'
				 when AffiliateID in (10,164,166) then 'Tenet'
				 else 'UHS'  end) as Affiliate,
	(case when BusinessDays>=7 then '7+' else cast(BusinessDays as nvarchar(2)) end) as BusinessDays ,COUNT(*) AS Total 
	from #tempFirstAttempt
		 GROUP BY (case when AffiliateID in (147,159) then 'CHI'
	             when AffiliateID in (4,5) then 'HCA'
				 when AffiliateID in (10,164,166) then 'Tenet'
				 else 'UHS' end),
				 (case when BusinessDays >=7 then '7+' else cast(BusinessDays as nvarchar(2)) end)) b
		 on a.NumberOfDays = b.BusinessDays
		 ORDER by a.NumberOfDays desc,b.Affiliate asc

SELECT NumberOfDays , 
[HCA], [CHI], [Tenet], [UHS]
FROM
(SELECT NumberOfDays,Affiliate, Coalesce(Total, 0) as Total
    FROM #tempsecondattempt) AS SourceTable
PIVOT
(
sum(Total)
FOR Affiliate IN ([HCA], [CHI], [Tenet], [UHS])
) AS PivotTable
ORDER by NumberOfDays desc


DROP TABLE #tempFirstAttempt
DROP TABle #tempsecondattempt


END
