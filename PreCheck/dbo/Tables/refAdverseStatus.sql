CREATE TABLE [dbo].[refAdverseStatus] (
    [refAdverseStatusID] INT          NOT NULL,
    [Status]             VARCHAR (50) NULL,
    [IsInactive]         BIT          NULL,
    [statusGroup]        VARCHAR (50) NULL,
    [IsPreAdverse]       BIT          NULL,
    [IsConclusiveStage]  BIT          NULL,
    CONSTRAINT [PK_refAdverseStatus] PRIMARY KEY CLUSTERED ([refAdverseStatusID] ASC) WITH (FILLFACTOR = 50)
);

