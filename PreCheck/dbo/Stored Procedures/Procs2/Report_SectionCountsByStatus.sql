
CREATE Procedure [dbo].[Report_SectionCountsByStatus]
(@StartDate Datetime,
 @EndDate as Datetime,
 @CLNO INT = 0) AS
BEGIN
/*
Author: Santosh Chapyala
CreatedDate: 10/15/2010
Returns: Section count for a given date range by client
Purpose: QReport

Example:
Report_SectionCountsByDateRangeByCLNO '1/1/2010','12/31/2010',1937

*/
	SET NOCOUNT ON

	Declare @CorrectedEndDate Datetime

	Set @CorrectedEndDate = DateAdd(d,1,@EndDate)

	Select 'Empl' Section, count(1) Counts,description,@StartDate StartDate,@EndDate EndDate from empl e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join sectstat s on e.sectstat = s.Code
	where apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and ishidden=0 and IsOnReport = 1 
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by description
	Union all
	Select 'Educat' Section, count(1) Counts,description,@StartDate StartDate,@EndDate EndDate from educat e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join sectstat s on e.sectstat = s.Code
	where apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and ishidden=0 and IsOnReport = 1   
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by description 
	Union all
	Select 'ProfLic' Section, count(1) Counts,description,@StartDate StartDate,@EndDate EndDate from profLic e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join sectstat s on e.sectstat = s.Code
	where apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and ishidden=0 and IsOnReport = 1   
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by description
	Union all
	Select 'PersRef' Section, count(1) Counts,description,@StartDate StartDate,@EndDate EndDate from persref e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join sectstat s on e.sectstat = s.Code
	where apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and ishidden=0 and IsOnReport = 1   
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by description
	Union all
	Select 'Credit' Section, count(1) Counts,description,@StartDate StartDate,@EndDate EndDate from Credit e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join sectstat s on e.sectstat = s.Code
	where apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and reptype = 'C' and ishidden=0    
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by description
	Union all
	Select 'Positiveid' Section, count(1) Counts,description,@StartDate StartDate,@EndDate EndDate from Credit e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join sectstat s on e.sectstat = s.Code
	where apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and reptype = 'S' and ishidden=0    
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by description
	Union all
	Select 'SanctionCheck' Section, count(1) Counts,description,@StartDate StartDate,@EndDate EndDate from MedInteg e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join sectstat s on e.sectstat = s.Code
	where apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and ishidden=0  
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by description
	Union all
	Select 'MVR-DL' Section, count(1) Counts,description,@StartDate StartDate,@EndDate EndDate from DL e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join sectstat s on e.sectstat = s.Code
	where --apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and ishidden=0   
	e.CreatedDate >=@StartDate and e.CreatedDate < @CorrectedEndDate
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by description
	Union all
	Select 'Crim' Section, count(1) Counts,crimdescription description,@StartDate StartDate,@EndDate EndDate from Crim e (nolock) inner join appl a  (nolock) on e.apno = a.apno 
	inner join Crimsectstat s on e.Clear = s.crimsect
	where apdate>=@StartDate and apdate <@CorrectedEndDate and apstatus='F' and ishidden=0   
	AND (a.CLNO = @CLNO OR @CLNO = 0) group by crimdescription

	SET NOCOUNT OFF
END
