CREATE Procedure [dbo].[ReportClientManagerDetails]
@CLNO INT AS
BEGIN
/*
Author: Bernie Chan
CreatedDate: 1/21/2015
Returns: Client Manager Details for a given CLNO
Purpose: QReport
--exec [dbo].[ReportClientManagerDetails] 2135
*/
	SET NOCOUNT ON

	SELECT 
      CASE WHEN [PrimaryContact] = 0 THEN 'No' ELSE 'Yes' END AS 'Primary'
      ,[ContactType] AS 'Contact Type'
      ,CASE WHEN [ReportFlag] = 0 THEN 'No' ELSE 'Yes' END AS 'Gets Report'
      ,[Title]
      ,[FirstName] AS 'First Name'
      ,[MiddleName] AS 'Middle Name'
      ,[LastName] AS 'Last Name'
      ,[Phone]
      ,[Ext]
      ,[Email]
      ,[username] AS 'User Name'
      ,[UserPassword] AS 'Password'
      ,CASE WHEN [WOLockout] = 0 THEN 'No' ELSE 'Yes' END AS 'Locked Out'
      ,CASE WHEN [IsActive] = 0 THEN 'No' ELSE 'Yes' END AS 'Active'
  FROM [PreCheck].[dbo].[ClientContacts]
  WHERE CLNO = @CLNO

	SET NOCOUNT OFF
END