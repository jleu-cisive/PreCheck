-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetNumberofSexOffendersAuto_Manual]
	-- Add the parameters for the stored procedure here
@StartDate DateTime = '2013-03-11 00:00:00.000',
@EndDate DateTime = '2013-04-15 00:00:00.000',
@County varchar(50) = 'SEX OFFENDER'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @totalcount int, @Autoordered int

--old totalcount formula, changed by liel as per Charles Sours Ticket ID: 4189
--select @totalcount =  count(1) from crim where county like '%SEX OFFENDER%' and Crimenteredtime between @StartDate and @EndDate 

select @totalcount =  count(1) from crim where county like '%' + @County + '%' and Crimenteredtime between @StartDate and @EndDate


select @Autoordered = count(1) from IrisAliasUpdate_Autocheck_log l inner join  crim on l.crimid = crim.Crimid where crim.county like '%' + @County + '%' and l.Crimenteredtime between @StartDate and @EndDate

select
@totalcount as totalcount,@Autoordered as Autoordered , (@totalcount - @Autoordered) as ManualOrdered
END
