CREATE TABLE [dbo].[ReportUploadVolume] (
    [ReportUploadVolumeID] INT            IDENTITY (1, 1) NOT NULL,
    [VolumeLabel]          VARCHAR (100)  NULL,
    [ClientFacilityGroup]  VARCHAR (50)   NULL,
    [ForClient]            INT            NULL,
    [StartDate]            DATETIME       NULL,
    [EndDate]              DATETIME       NULL,
    [ImageCount]           INT            NULL,
    [ReportType]           INT            NULL,
    [UploadDate]           DATETIME       NULL,
    [CreatedDate]          DATETIME       NULL,
    [Error]                NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ReportUploadVolume] PRIMARY KEY CLUSTERED ([ReportUploadVolumeID] ASC) WITH (FILLFACTOR = 50)
);

