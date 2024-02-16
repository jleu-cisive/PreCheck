CREATE TABLE [dbo].[hrxml_result_status] (
    [code]        VARCHAR (25)  NOT NULL,
    [description] VARCHAR (100) NULL,
    CONSTRAINT [pk_hrxml_result_status] PRIMARY KEY CLUSTERED ([code] ASC) WITH (FILLFACTOR = 50)
);

