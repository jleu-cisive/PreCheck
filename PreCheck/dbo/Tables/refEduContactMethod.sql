CREATE TABLE [dbo].[refEduContactMethod] (
    [refEduContactMethodID] INT          IDENTITY (1, 1) NOT NULL,
    [Description]           VARCHAR (50) NULL,
    CONSTRAINT [PK_refEduContactMethod] PRIMARY KEY CLUSTERED ([refEduContactMethodID] ASC) WITH (FILLFACTOR = 50)
);

