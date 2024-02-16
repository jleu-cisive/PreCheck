﻿CREATE TABLE [dbo].[ZipCodeWorld] (
    [ZIP_CODE]         NVARCHAR (255) NULL,
    [CITY]             VARCHAR (100)  NULL,
    [STATE]            VARCHAR (100)  NULL,
    [AREA_CODE]        NVARCHAR (255) NULL,
    [CITY_ALIAS_NAME]  NVARCHAR (255) NULL,
    [CITY_ALIAS_ABBR]  NVARCHAR (255) NULL,
    [CITY_TYPE]        NVARCHAR (255) NULL,
    [COUNTY_NAME]      NVARCHAR (255) NULL,
    [COUNTY_FIPS]      NVARCHAR (255) NULL,
    [TIME_ZONE]        NVARCHAR (255) NULL,
    [DAY_LIGHT_SAVING] NVARCHAR (255) NULL,
    [LATITUDE]         NVARCHAR (255) NULL,
    [LONGITUDE]        NVARCHAR (255) NULL,
    [ELEVATION]        NVARCHAR (255) NULL
) ON [PRIMARY];
