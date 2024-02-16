-- =============================================
-- Author:		Suchitra Yellapantula
-- Create date: 03/29/2017
-- Description:	For Q-Report which pulls all the Apps for which the SSN has been updated within the input date range, per HDT #12539 requested by Valerie K. Salazar
-- Execution:  exec dbo.ApplsWithChangedSSN_ByDateRange '03/01/2017','03/02/2017',11725,'HCA'
-- =============================================
CREATE PROCEDURE [dbo].[ApplsWithChangedSSN_ByDateRange] 
	-- Add the parameters for the stored procedure here
    @StartDate date, 
    @EndDate date,
	@CLNO int,
	@Affiliate varchar(100) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

set @Affiliate=LTRIM(RTRIM(@Affiliate))

if(@Affiliate='' or @Affiliate is null or LOWER(@Affiliate)='null')
begin
 set @Affiliate = ''
end

if (@CLNO is null or LOWER(@CLNO)='null')
begin
set @CLNO=0
end


select A.CLNO [Client Number],CL.Name [Client Name],RA.Affiliate,A.EnteredVia,A.APNO [Report Number], A.First [Applicant First Name], A.Last [Applicant Last Name], 'SSN' as [Modified Field],C.OldValue, C.NewValue, C.ChangeDate, C.UserID
from ChangeLog C (nolock) 
inner join Appl A on A.APNO = C.ID
inner join Client CL on CL.CLNO = A.CLNO
inner join refAffiliate RA on RA.AffiliateID = CL.AffiliateID
where TableName='Appl.SSN' and ChangeDate>=@StartDate and ChangeDate<dateadd(day,1,@EndDate)
and (@CLNO=0 or CL.CLNO = @CLNO)
and (@Affiliate='' or RA.Affiliate = LTRIM(RTRIM(@Affiliate)))
END



