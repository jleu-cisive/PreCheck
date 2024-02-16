CREATE TABLE [dbo].[WinServiceTimeType] (
    [ID]          INT          IDENTITY (1, 1) NOT NULL,
    [ServiceType] VARCHAR (10) NULL,
    CONSTRAINT [PK_WinServiceTimeType] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

