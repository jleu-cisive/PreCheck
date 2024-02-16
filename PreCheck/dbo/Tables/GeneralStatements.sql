CREATE TABLE [dbo].[GeneralStatements] (
    [StatementID]   INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]          INT           NOT NULL,
    [Statement]     VARCHAR (700) NOT NULL,
    [StatementType] VARCHAR (10)  NULL,
    [IsMandatory]   BIT           NULL,
    CONSTRAINT [PK_GeneralStatement] PRIMARY KEY CLUSTERED ([StatementID] ASC) WITH (FILLFACTOR = 50)
);

