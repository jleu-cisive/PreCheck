CREATE TABLE [dbo].[ClientWeight] (
    [CLNO]       INT          NOT NULL,
    [WeightType] VARCHAR (15) NOT NULL,
    [Weight]     FLOAT (53)   NULL,
    CONSTRAINT [PK_ClientWeight] PRIMARY KEY CLUSTERED ([CLNO] ASC, [WeightType] ASC) WITH (FILLFACTOR = 50)
);

