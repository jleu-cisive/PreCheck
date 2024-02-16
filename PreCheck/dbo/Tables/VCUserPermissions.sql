CREATE TABLE [dbo].[VCUserPermissions] (
    [VCUserPermissionsID] INT           IDENTITY (1, 1) NOT NULL,
    [UserID]              VARCHAR (50)  NOT NULL,
    [Permissions]         VARCHAR (100) NULL,
    [Sections]            VARCHAR (100) NULL,
    [Isactive]            BIT           DEFAULT ((1)) NULL,
    [CreateDate]          DATETIME      DEFAULT (getdate()) NULL,
    [CreateBy]            INT           DEFAULT ((0)) NULL,
    [ModifyDate]          DATETIME      DEFAULT (getdate()) NULL,
    [ModifyBy]            INT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([VCUserPermissionsID] ASC)
);

