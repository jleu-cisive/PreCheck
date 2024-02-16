CREATE TABLE [dbo].[ZipCode] (
    [Zip]   CHAR (5)     NOT NULL,
    [City]  VARCHAR (25) NOT NULL,
    [State] CHAR (2)     NOT NULL,
    CONSTRAINT [PK_ZipCode] PRIMARY KEY CLUSTERED ([Zip] ASC) WITH (FILLFACTOR = 50)
);

