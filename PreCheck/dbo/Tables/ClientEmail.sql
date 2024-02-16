CREATE TABLE [dbo].[ClientEmail] (
    [AccountNumbers] VARCHAR (1000) NOT NULL,
    [CLNO]           VARCHAR (100)  NOT NULL,
    [ClientName]     VARCHAR (1000) NOT NULL,
    [Name]           VARCHAR (1000) NOT NULL,
    [Phone]          VARCHAR (500)  NOT NULL,
    [Email1]         VARCHAR (1000) NOT NULL,
    [Email2]         VARCHAR (1000) NULL,
    [CreatedDate]    DATETIME       NOT NULL,
    [ID]             INT            IDENTITY (1, 1) NOT NULL
);

