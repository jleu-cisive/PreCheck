CREATE TABLE [dbo].[RefCrimStages] (
    [RefCrimStageID] INT           IDENTITY (1, 1) NOT NULL,
    [Stage]          VARCHAR (100) NULL,
    [Description]    VARCHAR (100) NULL,
    [IsActive]       BIT           CONSTRAINT [DF_RefCrimStages_IsActive] DEFAULT ((0)) NOT NULL,
    [CreateDate]     DATETIME      CONSTRAINT [DF_RefCrimStages_CreateDate] DEFAULT (getdate()) NULL,
    [CreatedBy]      VARCHAR (20)  NULL,
    [UpdateDate]     DATETIME      CONSTRAINT [DF_RefCrimStages_UpdateDate] DEFAULT (getdate()) NULL,
    [UpdatedBy]      VARCHAR (20)  NULL,
    CONSTRAINT [PK_RefCrimStages] PRIMARY KEY CLUSTERED ([RefCrimStageID] ASC) WITH (FILLFACTOR = 70)
);

