CREATE TABLE [dbo].[HTMLParser] (
    [HTMLParserID] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]         INT          NULL,
    [MapNumber]    INT          NULL,
    [TableName]    VARCHAR (80) NULL,
    [ColumnName]   VARCHAR (80) NULL,
    [IsActive]     BIT          NOT NULL,
    [Length]       INT          NOT NULL,
    [Group]        INT          NULL,
    CONSTRAINT [PK_HTMLParser] PRIMARY KEY CLUSTERED ([HTMLParserID] ASC) WITH (FILLFACTOR = 50)
);

