CREATE ROLE [db_executor]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [db_executor] ADD MEMBER [PRECHECK\BISUsers];


GO
ALTER ROLE [db_executor] ADD MEMBER [PRECHECK\gbangia];


GO
ALTER ROLE [db_executor] ADD MEMBER [dpsuser];


GO
ALTER ROLE [db_executor] ADD MEMBER [VendorCheck];


GO
ALTER ROLE [db_executor] ADD MEMBER [PRECHECK\Trust - CarcoGroup - BISUsers];


GO
ALTER ROLE [db_executor] ADD MEMBER [PRECHECK\HOU-IIS-01$];

