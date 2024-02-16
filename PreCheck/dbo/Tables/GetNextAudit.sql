CREATE TABLE [dbo].[GetNextAudit] (
    [GetNextAuditId] INT             IDENTITY (1, 1) NOT NULL,
    [Apno]           INT             NOT NULL,
    [EmplId]         INT             NOT NULL,
    [OldValue]       VARCHAR (50)    NULL,
    [NewValue]       VARCHAR (50)    NULL,
    [Description]    NVARCHAR (1000) NULL,
    [CreatedDate]    DATETIME        CONSTRAINT [DF_GetNextAudit_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)    CONSTRAINT [DF_GetNextAudit_CreatedBy] DEFAULT ('Service') NOT NULL,
    [UpdateDate]     DATETIME        CONSTRAINT [DF_GetNextAudit_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]      VARCHAR (50)    CONSTRAINT [DF_GetNextAudit_UpdatedBy] DEFAULT ('Service') NOT NULL,
    CONSTRAINT [PK_GetNextAudit] PRIMARY KEY CLUSTERED ([GetNextAuditId] ASC) WITH (FILLFACTOR = 70)
);

