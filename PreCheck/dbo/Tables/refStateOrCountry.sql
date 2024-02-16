CREATE TABLE [dbo].[refStateOrCountry] (
    [refStateOrCountryID] INT          IDENTITY (1, 1) NOT NULL,
    [ComboName]           VARCHAR (50) NULL,
    [Name2]               VARCHAR (2)  NULL,
    [FullName]            VARCHAR (50) NULL,
    [IsCountry]           BIT          NULL,
    [Hide]                BIT          NULL,
    CONSTRAINT [PK_refStateOrCountry] PRIMARY KEY CLUSTERED ([refStateOrCountryID] ASC) WITH (FILLFACTOR = 50)
);

