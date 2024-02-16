
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[WS_GetPackageOptions] 
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT 'Criminal Background' as SERVICEOPTION,Isnull((SELECT top 1 criminalbox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION 
SELECT 'License/Certificate Verification' AS SERVICEOPTION,Isnull((SELECT top 1 licensebox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION 
SELECT 'SanctionCheck' as SERVICEOPTION,Isnull((SELECT top 1 medicaidbox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION 
SELECT 'Positive Identification' AS SERVICEOPTION,Isnull((SELECT top 1 ssnbox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION
SELECT 'Education Verification' AS SERVICEOPTION,Isnull((SELECT top 1 educationbox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION 
SELECT 'Employment Verification' as SERVICEOPTION,Isnull((SELECT top 1 employeebox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION 
SELECT 'Personal References' AS SERVICEOPTION,Isnull((SELECT top 1 personalbox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION 
SELECT 'Credit Report' as SERVICEOPTION,Isnull((SELECT top 1 creditreportbox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION 
SELECT 'Motor Vehicle Report' as SERVICEOPTION,Isnull((SELECT top 1 motorvehiclebox from weborder_prx.dbo.services WHERE clientid = @CLNO),0) as DEFAULTVALUE
UNION
SELECT 'US District Federal Court Search' as SERVICEOPTION,0 as DEFAULTVALUE
UNION 
SELECT 'Federal Bankruptcy Search' as SERVICEOPTION,0 as DEFAULTVALUE
UNION 
SELECT 'Newspaper & Article Clippings (90 Day)' as SERVICEOPTION,0 as DEFAULTVALUE
UNION 
SELECT 'US Civil Search' as SERVICEOPTION,0 as DEFAULTVALUE
END

