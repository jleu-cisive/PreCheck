-- ====================================================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: 01/09/2017
-- Description:	Query for Q-Report 'Employment records set to Third Party by Date Range' that shows all of the employment items that were once set to web status THIRD PARTY
-- Execution: exec Empls_Set_To_ThirdParty_ByDateRange '2016-11-01','2016-11-07'
-- ====================================================================================================================
CREATE PROCEDURE Empls_Set_To_ThirdParty_ByDateRange
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate date
AS
BEGIN


select E.APNO, E.Employer as 'Employer Name', cast(L.ChangeDate as date) as 'Date Set to Third Party Web Status' 
from ChangeLog L with (nolock) inner join Empl E on L.ID = E.EmplID
where TableName='Empl.web_status' and NewValue=76 and L.ChangeDate>=@StartDate and L.ChangeDate<(dateadd(day,1,@EndDate))
order by L.ChangeDate asc

END
