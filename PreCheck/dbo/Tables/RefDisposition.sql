CREATE TABLE [dbo].[RefDisposition] (
    [RefDispositionID]     INT           IDENTITY (1, 1) NOT NULL,
    [Disposition]          VARCHAR (100) NULL,
    [Description]          VARCHAR (100) NULL,
    [refDispositionTypeID] INT           NOT NULL,
    [IsActive]             BIT           CONSTRAINT [DF_RefDisposition_IsActive] DEFAULT ((0)) NOT NULL,
    [CreateDate]           DATETIME      CONSTRAINT [DF_RefDisposition_CreateDate] DEFAULT (getdate()) NULL,
    [CreatedBy]            VARCHAR (20)  NULL,
    [UpdateDate]           DATETIME      CONSTRAINT [DF_RefDisposition_UpdateDate] DEFAULT (getdate()) NULL,
    [UpdatedBy]            VARCHAR (20)  NULL,
    CONSTRAINT [PK_RefDisposition] PRIMARY KEY CLUSTERED ([RefDispositionID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_RefDisposition_RefDispositionType] FOREIGN KEY ([refDispositionTypeID]) REFERENCES [dbo].[RefDispositionType] ([RefDispositionTypeID])
);

