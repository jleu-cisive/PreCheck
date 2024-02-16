
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 06/03
-- Description:	A Q report to look up nursys licenses
--Example
--dbo.qr_NusysLookupByTypeAndState 'SC','RN'
-- =============================================
CREATE PROCEDURE [dbo].[qr_NusysLookupByTypeAndState] 
	-- Add the parameters for the stored procedure here
	@state varchar(2),
	@type varchar(5)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 
		--distinct (l.IssuingState + '-' + lt.ItemValue) as licensetype,
		l.IssuingState as [License State],
		lt.ItemValue as [License Type]
		,er.First,er.Last,expiresdate as [Expiration Date],
	case when IsNull(status,'') = '' then 'No Status' else Status end as [License Status]
	/*
	case when lri.IsActive = 1 then 'true' else 'false' end as IsActive
	case 
		when lri.ActionCode = 'A' then 'To be ADDED' 
		when lri.ActionCode='R' then 'to be REMOVED' 
		else 
			'NO CHANGE' 
	end as Action */
	from HEVN.dbo.EmployeeRecord er (nolock) inner join HEVN.dbo.License l (nolock) on er.EmployeeRecordID = l.EmployeeRecordID
	inner join HEVN.dbo.[LicenseRoster_Integration] lri (nolock) on l.LicenseId = lri.LicenseID inner join HEVN.dbo.LicenseType lt (nolock) on l.LicenseTypeID = lt.LicenseTypeID
	where l.IssuingState = @state and ItemValue=@type order by ExpiresDate desc
END
