CREATE TABLE [dbo].[hrxml_screening_order_status] (
    [code]        VARCHAR (25)  NOT NULL,
    [description] VARCHAR (100) NULL,
    CONSTRAINT [PK_hrxml_screening_order_status] PRIMARY KEY CLUSTERED ([code] ASC) WITH (FILLFACTOR = 50)
);

