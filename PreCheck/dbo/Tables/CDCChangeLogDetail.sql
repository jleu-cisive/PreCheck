CREATE TABLE [dbo].[CDCChangeLogDetail] (
    [ChangeLogDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [ChangeLogId]       INT            NOT NULL,
    [KeyColumnValue]    VARCHAR (255)  NOT NULL,
    [OldValue]          VARCHAR (1000) NULL,
    [NewValue]          VARCHAR (1000) NULL,
    [ChangeDate]        DATETIME       CONSTRAINT [DF_ChangelogDtl_CreatedBy] DEFAULT (suser_name()) NULL,
    [ChangedBy]         VARCHAR (50)   CONSTRAINT [DF_ChangelogDtl_CreatedDt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ChangelogDtl] PRIMARY KEY CLUSTERED ([ChangeLogDetailId] ASC) WITH (FILLFACTOR = 70),
    FOREIGN KEY ([ChangeLogId]) REFERENCES [dbo].[CDCChangeLog] ([ChangeLogId])
);


GO
CREATE NONCLUSTERED INDEX [IDX_ChangeLogID_INC]
    ON [dbo].[CDCChangeLogDetail]([ChangeLogId] ASC, [ChangeDate] ASC)
    INCLUDE([ChangeLogDetailId], [KeyColumnValue], [NewValue], [OldValue]);

