CREATE TABLE [dbo].[tblZipCrimStatusMapping] (
    [ZipCrimStatusMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [Status]                 VARCHAR (MAX) NOT NULL,
    [MappedStatus]           VARCHAR (MAX) NOT NULL,
    [IsActive]               BIT           NOT NULL,
    CONSTRAINT [ZipCrimStatusMappingId] PRIMARY KEY CLUSTERED ([ZipCrimStatusMappingId] ASC) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

