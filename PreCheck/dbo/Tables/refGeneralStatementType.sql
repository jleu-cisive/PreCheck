CREATE TABLE [dbo].[refGeneralStatementType] (
    [GeneralStatementTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [GeneralStatementType]   VARCHAR (10) NULL,
    CONSTRAINT [PK_GeneralStatementTypeID] PRIMARY KEY CLUSTERED ([GeneralStatementTypeID] ASC) WITH (FILLFACTOR = 50)
);

