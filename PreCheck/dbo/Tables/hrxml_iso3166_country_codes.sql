CREATE TABLE [dbo].[hrxml_iso3166_country_codes] (
    [code]    CHAR (2)   NOT NULL,
    [country] NCHAR (50) NOT NULL,
    CONSTRAINT [pk_hrxml_iso3166_country_codes] PRIMARY KEY CLUSTERED ([code] ASC) WITH (FILLFACTOR = 50)
);

