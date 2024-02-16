-- =============================================
-- Author:		Humera Ahmed
-- Create date: 10/25/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LMP Deficiency Report]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT er.EmployerID,c.Name,er.First + ' '+  er.Last AS 'License Name',l.IssuingState AS 'State',l.Type,l.LicenseID, 
(SELECT CONVERT(VARCHAR, l.LastModifiedDate, 101) + ' ' + CONVERT(CHAR(5),l.LastModifiedDate, 108)) AS [Last Cannot Verify Date] --l.LastModifiedDate AS 'Last Cannot Verify Date'
, l.CredentialingStatus, l.VerifiedBy FROM license l 
INNER JOIN dbo.EmployeeRecord er ON l.ssn = er.ssn AND l.Employer_ID=er.EmployerID AND er.EmployeeRecordID= l.EmployeeRecordID
INNER JOIN precheck.dbo.Client c on c.CLNO=l.Employer_ID
WHERE 
l.CredentialingStatus=3 AND l.Employer_ID = 7519 AND er.EndDate IS NULL
AND l.LastModifiedDate>='10/1/2018' AND l.LastModifiedDate	<='10/31/2018'
ORDER BY l.LastModifiedDate DESC
END
