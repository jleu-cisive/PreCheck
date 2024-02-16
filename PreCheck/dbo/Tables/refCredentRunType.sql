CREATE TABLE [dbo].[refCredentRunType] (
    [refCredentRunTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [RunType]             VARCHAR (50) NULL,
    CONSTRAINT [PK_refCredentRunType] PRIMARY KEY CLUSTERED ([refCredentRunTypeID] ASC) WITH (FILLFACTOR = 50)
);

