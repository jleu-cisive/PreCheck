-- =============================================
-- Author:		Raymundo Lopez
-- Create date: 02/24/2019
-- Description:	Gives us the buniness days (by not considering PreCheck holidays, this is done for performance purposes, holidays would need to be considered in the main query calling this function)
-- =============================================
CREATE FUNCTION [dbo].[fnGetBusinessDaysWithHolidays]
(
     @StartDate datetime,
     @EndDate datetime
) 
RETURNS int
AS
BEGIN

       DECLARE @BusinessDays int = 0
       SET @BusinessDays = (SELECT 
              (DATEDIFF(dd, @StartDate, @EndDate) + 1)-(DATEDIFF(wk, @StartDate, @EndDate) * 2)-(CASE WHEN DATENAME(dw, @StartDate) = 'Sunday' THEN 1 ELSE 0 END)
              - (CASE WHEN DATENAME(dw, @EndDate) = 'Saturday' THEN 1 ELSE 0 END))

       RETURN @BusinessDays

END

