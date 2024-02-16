CREATE TABLE [dbo].[WNList] (
    [EmployerCode] VARCHAR (100) NULL,
    [Name1]        VARCHAR (255) NULL,
    [WNListId]     INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_WNlist] PRIMARY KEY CLUSTERED ([WNListId] ASC) WITH (FILLFACTOR = 70)
);

