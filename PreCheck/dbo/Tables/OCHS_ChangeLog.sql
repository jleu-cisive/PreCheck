CREATE TABLE [dbo].[OCHS_ChangeLog] (
    [OCHS_ChangeLogID] INT            IDENTITY (1, 1) NOT NULL,
    [TableName]        VARCHAR (150)  NULL,
    [ID]               INT            NULL,
    [OldValue]         VARCHAR (8000) NULL,
    [NewValue]         VARCHAR (8000) NULL,
    [ChangeDate]       DATETIME       CONSTRAINT [DF_OCHS_ChangeLog_ChangeDate] DEFAULT (getdate()) NULL,
    [UserID]           VARCHAR (50)   NULL,
    CONSTRAINT [PK_OCHS_ChangeLog_1001] PRIMARY KEY CLUSTERED ([OCHS_ChangeLogID] ASC) WITH (FILLFACTOR = 50)
);

