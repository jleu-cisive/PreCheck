CREATE TABLE [dbo].[ZipCodeWorldZones] (
    [ZipCodeWorldZonesID] INT          IDENTITY (1, 1) NOT NULL,
    [Time_Zone]           CHAR (2)     NULL,
    [TimeZoneName]        VARCHAR (50) NULL,
    CONSTRAINT [PK_ZipCodeWorldZones] PRIMARY KEY CLUSTERED ([ZipCodeWorldZonesID] ASC) WITH (FILLFACTOR = 50)
);

