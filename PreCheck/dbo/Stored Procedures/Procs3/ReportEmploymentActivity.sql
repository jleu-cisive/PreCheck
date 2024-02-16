/*
Author: Bernie Chan
CreatedDate: 1/15/2015
Returns: Employment Activity for a given date range by User ID
Purpose: QReport
Execution: [dbo].[ReportEmploymentActivity] 'CClark', '05/09/2018', '05/11/2018'
		   [dbo].[ReportEmploymentActivity] NULL, '05/09/2018', '05/11/2018'
		   [dbo].[ReportEmploymentActivity] '', '05/09/2018', '05/11/2018'
		   [dbo].[ReportEmploymentActivity] 0, '05/09/2018', '05/11/2018'
*/

CREATE Procedure [dbo].[ReportEmploymentActivity]
	@USERID VARCHAR(50) = NULL,
	@StartDate Datetime,
	@EndDate as Datetime
 
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		e.Apno,
		EmplID,
		Employer,
		s.[Description],
		w.[description] AS 'Web Status',
		e.Investigator,
		--(SELECT TOP 1 history_status FROM [PreCheck].[dbo].[Web_status_history] WHERE emplid = e.EmplID AND history_appno = e.Apno ORDER BY history_date DESC) AS 'Previous Web Status',
		[Location],
		CASE WHEN Worksheet = 0 THEN 'No' ELSE 'Yes' END AS Worksheet,
		e.Phone,
		Supervisor,
		SupPhone,
		Dept,
		RFL,
		CASE WHEN DNC = 0 THEN 'No' ELSE 'Yes' END AS DNC,
		CASE WHEN SpecialQ = 0 THEN 'No' ELSE 'Yes' END AS SpecialQ,
		CASE WHEN Ver_Salary = 0 THEN 'No' ELSE 'Yes' END AS 'Verified Salary',
		From_A AS 'Employer From (Per Application)',
		To_A AS 'Employer To (Per Application)',
		Position_A AS 'Position (Per Application)',
		Salary_A AS 'Salary (Per Application)',
		From_V AS 'Employer From (Verification)',
		To_V  AS 'Employer To (Verification)',
		Position_V AS 'Position (Verification)',
		Salary_V AS 'Salary (Verification)',
		t.Emp_Description AS 'Type',
		c.Rel_Description AS 'Rel Cond',
		r.Description AS 'Rehire',
		Ver_By AS 'Verified By',
		Title,
		REPLACE(REPLACE(Priv_Notes, char(10),';'),char(13),';') AS 'Private Notes',
		REPLACE(REPLACE(Pub_Notes, char(10),';'),char(13),';') AS 'Public Notes'
	FROM [PreCheck].[dbo].[Empl] AS e(NOLOCK)
	LEFT OUTER JOIN [PreCheck].[dbo].[Empl_Type_Stat] t(NOLOCK) ON e.Emp_Type = t.Emp_Type
	LEFT OUTER JOIN [PreCheck].[dbo].[Rel_Cond_Stat] c(NOLOCK) ON e.Rel_Cond = c.Rel_cond
	LEFT OUTER JOIN [PreCheck].[dbo].[Empl_Rehire_stat] r(NOLOCK) on e.Rehire = r.Rehire
	INNER JOIN [PreCheck].[dbo].[SectStat] s(NOLOCK) on e.SectStat = s.Code
	INNER JOIN [PreCheck].[dbo].[Websectstat] w(NOLOCK) on e.web_status = w.code
	WHERE (@USERID IS NULL OR @USERID = '' OR @USERID = 0 OR e.Investigator = @USERID) 
	  AND e.web_updated >= @StartDate 
	  AND e.web_updated <= @EndDate 
	  AND (s.Code = '5' OR s.Code = '6')

	SET NOCOUNT OFF
END
