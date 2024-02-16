-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_GetTopTenLicenses] 
	-- Add the parameters for the stored procedure here
	@LicenseState varchar(20),
	@LicenseType varchar(40)

AS
BEGIN
	select top 10 l.LicenseID,l.Type, l.IssuingState, er.First, er.Last, l.Number,l.SSN, er.DOB from [HEVN].[dbo].License l (nolock) inner join [HEVN].[dbo].EmployeeRecord er on l.EmployeeRecordID = er.EmployeeRecordID  where l.IssuingState = @LicenseState and l.Type = @LicenseType
END
