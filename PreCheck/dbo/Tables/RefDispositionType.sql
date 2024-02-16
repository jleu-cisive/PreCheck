CREATE TABLE [dbo].[RefDispositionType] (
    [RefDispositionTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [DispositionType]      VARCHAR (100) NULL,
    [Description]          VARCHAR (100) NULL,
    [IsActive]             BIT           CONSTRAINT [DF_RefDispositionType_IsActive] DEFAULT ((0)) NOT NULL,
    [CreateDate]           DATETIME      CONSTRAINT [DF_RefDispositionType_CreateDate] DEFAULT (getdate()) NULL,
    [CreatedBy]            VARCHAR (20)  NULL,
    [UpdateDate]           DATETIME      CONSTRAINT [DF_RefDispositionType_UpdateDate] DEFAULT (getdate()) NULL,
    [UpdatedBy]            VARCHAR (20)  NULL,
    CONSTRAINT [PK_RefDispositionType] PRIMARY KEY CLUSTERED ([RefDispositionTypeID] ASC) WITH (FILLFACTOR = 50)
);

