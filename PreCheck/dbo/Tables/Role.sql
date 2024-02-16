CREATE TABLE [dbo].[Role] (
    [RoleId]          INT            IDENTITY (1, 1) NOT NULL,
    [RoleName]        VARCHAR (250)  NOT NULL,
    [DisplayName]     VARCHAR (250)  NOT NULL,
    [RoleDescription] VARCHAR (1000) NOT NULL,
    [HierarchyOrder]  INT            NULL,
    [ApplicationId]   INT            NOT NULL,
    [IsActive]        BIT            CONSTRAINT [DEF_Role_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]      DATETIME       CONSTRAINT [DEF_Role_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]        INT            NOT NULL,
    [ModifyDate]      DATETIME       CONSTRAINT [DEF_Role_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]        INT            NOT NULL,
    [ClientId]        INT            NULL,
    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([RoleId] ASC) ON [PRIMARY]
) ON [PRIMARY];

