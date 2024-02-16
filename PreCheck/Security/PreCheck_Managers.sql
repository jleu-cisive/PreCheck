CREATE ROLE [PreCheck_Managers]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [PreCheck_Managers] ADD MEMBER [PRECHECK\SQL_Managers];


GO
ALTER ROLE [PreCheck_Managers] ADD MEMBER [CarcoGroup.com\SQL_Managers];


GO
ALTER ROLE [PreCheck_Managers] ADD MEMBER [CARCOGROUP.COM\CDeCook];

