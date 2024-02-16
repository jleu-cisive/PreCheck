CREATE TABLE [dbo].[UserRolesBySection] (
    [UserRolesBySectionID] INT          IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]        INT          NOT NULL,
    [UserID]               VARCHAR (8)  NOT NULL,
    [refRoleID]            INT          NOT NULL,
    [IsActive]             BIT          CONSTRAINT [DF_UserRolesBySection_IsActive] DEFAULT ((0)) NOT NULL,
    [CreateDate]           DATETIME     NULL,
    [CreatedBy]            VARCHAR (20) NULL,
    [UpdateDate]           DATETIME     NULL,
    [UpdatedBy]            VARCHAR (20) NULL,
    CONSTRAINT [PK_UserRolesBySection] PRIMARY KEY CLUSTERED ([UserRolesBySectionID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_UserRolesBySection_ApplSections] FOREIGN KEY ([ApplSectionID]) REFERENCES [dbo].[ApplSections] ([ApplSectionID]),
    CONSTRAINT [FK_UserRolesBySection_refRoles] FOREIGN KEY ([refRoleID]) REFERENCES [dbo].[refRoles] ([refRoleID]),
    CONSTRAINT [FK_UserRolesBySection_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);

