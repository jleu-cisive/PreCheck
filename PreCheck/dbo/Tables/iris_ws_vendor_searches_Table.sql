CREATE TABLE [dbo].[iris_ws_vendor_searches_Table] (
    [id]                    BIGINT       IDENTITY (1, 1) NOT NULL,
    [vendor_id]             INT          NOT NULL,
    [county_id]             INT          NOT NULL,
    [search_type_qualifier] VARCHAR (25) NOT NULL,
    [court_type]            VARCHAR (25) NOT NULL,
    [vendor_type_id]        BIGINT       NOT NULL,
    [country_code]          CHAR (2)     NOT NULL,
    [region]                VARCHAR (50) NULL,
    [county]                VARCHAR (50) NULL,
    CONSTRAINT [pk_iris_ws_vendor_searches] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [fk_hrxml_vendor_search_qualifiers_country] FOREIGN KEY ([country_code]) REFERENCES [dbo].[hrxml_iso3166_country_codes] ([code]),
    CONSTRAINT [fk_hrxml_vendor_search_qualifiers_hrxml_county] FOREIGN KEY ([county_id]) REFERENCES [dbo].[TblCounties] ([CNTY_NO]),
    CONSTRAINT [fk_iris_ws_vendor_searches_court_type] FOREIGN KEY ([court_type]) REFERENCES [dbo].[hrxml_court_type_qualifier] ([code]),
    CONSTRAINT [fk_iris_ws_vendor_searches_search_type_qualifier] FOREIGN KEY ([search_type_qualifier]) REFERENCES [dbo].[hrxml_search_type_qualifier] ([code]),
    CONSTRAINT [fk_iris_ws_vendor_searches_vendor_type] FOREIGN KEY ([vendor_type_id]) REFERENCES [dbo].[iris_ws_vendor_type] ([id]),
    CONSTRAINT [ak_iris_ws_vendor_searches] UNIQUE NONCLUSTERED ([county_id] ASC, [vendor_id] ASC, [court_type] ASC, [search_type_qualifier] ASC) WITH (FILLFACTOR = 50) ON [PRIMARY]
);

