CREATE TABLE [dbo].[hrxml_court_type_qualifier] (
    [code]        VARCHAR (25)  NOT NULL,
    [description] VARCHAR (100) NULL,
    CONSTRAINT [PK_hrxml_court_type_qualifier] PRIMARY KEY CLUSTERED ([code] ASC) WITH (FILLFACTOR = 50)
);

