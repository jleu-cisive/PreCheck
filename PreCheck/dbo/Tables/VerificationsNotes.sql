CREATE TABLE [dbo].[VerificationsNotes] (
    [VerificationsNotesId] INT            IDENTITY (1, 1) NOT NULL,
    [Text]                 NVARCHAR (MAX) NOT NULL,
    [IsActive]             BIT            CONSTRAINT [DF_SJVNotes_isActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]           DATETIME       CONSTRAINT [DF_SJVNotes_createdDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            NVARCHAR (150) NULL,
    [ModifyDate]           DATETIME       CONSTRAINT [DF_SJVNotes_modifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]             NVARCHAR (150) NULL,
    CONSTRAINT [PK_SJVNotes] PRIMARY KEY CLUSTERED ([VerificationsNotesId] ASC) WITH (FILLFACTOR = 70)
);

