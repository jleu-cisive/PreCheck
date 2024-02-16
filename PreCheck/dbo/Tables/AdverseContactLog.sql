CREATE TABLE [dbo].[AdverseContactLog] (
    [AdverseContactLogID] INT IDENTITY (1, 1) NOT NULL,
    [AdverseActionID]     INT NULL,
    [AdverseContactID]    INT NULL,
    CONSTRAINT [PK_AdverseContactLog] PRIMARY KEY CLUSTERED ([AdverseContactLogID] ASC) WITH (FILLFACTOR = 50)
);

