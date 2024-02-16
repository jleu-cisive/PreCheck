
CREATE PROCEDURE [dbo].[ZipCrim_WorkOrder_GetSelfDisclosures] 
	@APNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT 
		ac.ApplicantCrimID,
		ac.CrimDate AS OccurrenceDate,
		NULL AS ConvictedDate,
		NULL AS SourceType,
		NULL AS ActionType,
		ac.[State],
		ac.City,
		NULL AS County,
		ac.Country AS CountryCode,
		Cast(1 AS bit) AS IsVisible,
		NULL AS DisclosureType,
		NULL AS CourtName,
		NULL AS Agency,
		NULL AS Status,
		NULL AS OutCome,
		NULL AS CourtAttendeeType,
		cast(0 AS bit) AS IsDeleted
	FROM dbo.ApplicantCrim ac
	WHERE ac.APNO = @APNO
END
