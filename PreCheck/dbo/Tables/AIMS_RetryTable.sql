CREATE TABLE [dbo].[AIMS_RetryTable] (
    [AIMS_RetryTableId]  INT IDENTITY (1, 1) NOT NULL,
    [AIMS_MappingId]     INT NOT NULL,
    [AIMS_SearchOrderId] INT NOT NULL,
    [AIMS_RetryCount]    INT NOT NULL,
    [AIMS_JobId]         INT NULL,
    CONSTRAINT [PK_dbo.AIMS_RetryTable_1] PRIMARY KEY CLUSTERED ([AIMS_RetryTableId] ASC) WITH (FILLFACTOR = 70)
);

