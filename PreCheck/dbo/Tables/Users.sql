CREATE TABLE [dbo].[Users] (
    [UserID]                      VARCHAR (8)   NOT NULL,
    [Passwd]                      VARCHAR (15)  NULL,
    [Name]                        VARCHAR (20)  NULL,
    [SecLevel]                    SMALLINT      CONSTRAINT [DF_Users_SecLevel] DEFAULT (0) NULL,
    [Disabled]                    BIT           CONSTRAINT [DF_Users_Disabled] DEFAULT (0) NOT NULL,
    [Investigator]                BIT           CONSTRAINT [DF_Users_Investigator] DEFAULT (0) NULL,
    [CanEditCounties]             BIT           CONSTRAINT [DF_Users_CanEditCounties] DEFAULT (0) NULL,
    [Sales]                       BIT           CONSTRAINT [DF_Users_Sales] DEFAULT (0) NULL,
    [SalesNo_MAS90]               INT           NULL,
    [EmailAddress]                VARCHAR (50)  CONSTRAINT [DF_Users_EmailAddress] DEFAULT (0) NULL,
    [empl]                        BIT           CONSTRAINT [DF_Users_empl] DEFAULT (0) NULL,
    [educat]                      BIT           CONSTRAINT [DF_Users_educat] DEFAULT (0) NULL,
    [persref]                     BIT           CONSTRAINT [DF_Users_persref] DEFAULT (0) NULL,
    [proflic]                     BIT           CONSTRAINT [DF_Users_proflic] DEFAULT (0) NULL,
    [Csr]                         BIT           CONSTRAINT [DF_Users_Csr] DEFAULT (0) NULL,
    [Criminal]                    BIT           CONSTRAINT [DF_Users_Criminal] DEFAULT (0) NULL,
    [ManageUsers]                 BIT           CONSTRAINT [DF_Users_ManageUsers] DEFAULT (0) NULL,
    [CanEditDropLists]            BIT           CONSTRAINT [DF_Users_CanEditDropLists] DEFAULT (0) NULL,
    [refAccessLevelID_LMS]        INT           CONSTRAINT [DF_Users_refAccessLevel_LMS] DEFAULT (1) NULL,
    [TaskRefPermissionID]         INT           CONSTRAINT [DF_Users_TaskPermissionID] DEFAULT (0) NOT NULL,
    [QualityControl]              BIT           CONSTRAINT [DF_Users_QualityControl] DEFAULT (0) NULL,
    [CanCloneApp]                 BIT           CONSTRAINT [DF_Users_CanCloneApp] DEFAULT (0) NOT NULL,
    [CanSetManager]               BIT           DEFAULT ((0)) NULL,
    [CanEditPermission]           BIT           DEFAULT ((0)) NULL,
    [CanEditDroplist]             BIT           DEFAULT ((0)) NULL,
    [CanCreateNewUser]            BIT           DEFAULT ((0)) NULL,
    [ShowAllUsers]                BIT           DEFAULT ((0)) NULL,
    [ManagerID]                   VARCHAR (8)   NULL,
    [InUse]                       VARCHAR (8)   NULL,
    [TemplateID]                  VARCHAR (8)   NULL,
    [IsTemplate]                  BIT           CONSTRAINT [DF_Users_IsTemplate] DEFAULT ((0)) NULL,
    [CAM]                         BIT           CONSTRAINT [DF_Users_CAM] DEFAULT ((0)) NULL,
    [HasStateBoardApprovalAccess] BIT           CONSTRAINT [DF_Users_HasStateBoardApprovalAccess] DEFAULT ((0)) NOT NULL,
    [CanDeleteApp]                BIT           DEFAULT ((0)) NOT NULL,
    [CanDeleteItem]               BIT           CONSTRAINT [DF_Users_CanDeleteItem] DEFAULT ((0)) NULL,
    [employeeID]                  VARCHAR (50)  NULL,
    [MGR]                         BIT           CONSTRAINT [DF_Users_MGR] DEFAULT ((0)) NULL,
    [Phone]                       VARCHAR (20)  NULL,
    [Department]                  VARCHAR (50)  NULL,
    [JobTitle]                    VARCHAR (100) NULL,
    [IsSCInvestigator]            BIT           DEFAULT ('FALSE') NULL,
    [ID]                          INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY NONCLUSTERED ([UserID] ASC) WITH (FILLFACTOR = 50) ON [FG_DATA]
) ON [PRIMARY];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'If true, the user can manage other users', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'ManageUsers';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Can Edit DropLists', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'CanEditDropLists';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Use in BIS3.FormUserPermission. Grant user the ability to manage other users.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'CanSetManager';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Use in BIS3.FormUserPermission. Grant user the ability to edit other user''s permissions.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'CanEditPermission';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Use in BIS3.FormUserPermission. Grant user the ability to edit other user''s departments.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'CanEditDroplist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The UserID of this user''s manager.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'ManagerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The UserID of this user''s template.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'TemplateID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Determine if the record is a user or template since both these records are stored in the same table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'IsTemplate';

