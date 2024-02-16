CREATE TABLE [dbo].[refAdverse] (
    [AdverseID]   INT          IDENTITY (1, 1) NOT NULL,
    [AdverseType] VARCHAR (20) NULL,
    CONSTRAINT [PK_refAdverse] PRIMARY KEY CLUSTERED ([AdverseID] ASC) WITH (FILLFACTOR = 50)
);

