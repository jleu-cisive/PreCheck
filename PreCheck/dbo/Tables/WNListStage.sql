CREATE TABLE [dbo].[WNListStage] (
    [EmployerCode] VARCHAR (100) NULL,
    [Name1]        VARCHAR (255) NULL,
    [WNListId]     INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_WNlistStage] PRIMARY KEY CLUSTERED ([WNListId] ASC) WITH (FILLFACTOR = 70)
);

