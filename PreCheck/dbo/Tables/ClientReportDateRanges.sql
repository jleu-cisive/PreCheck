CREATE TABLE [dbo].[ClientReportDateRanges] (
    [ClientReportDateRangeID] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                    SMALLINT     NOT NULL,
    [ReportName]              VARCHAR (50) NOT NULL,
    [StartDate]               DATETIME     NULL,
    [EndDate]                 DATETIME     NULL,
    [IsActive]                BIT          DEFAULT ((1)) NOT NULL,
    [CreatedBy]               VARCHAR (20) NULL,
    [CreatedDate]             DATETIME     CONSTRAINT [DF_ClientReportDateRanges_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedDate]        DATETIME     CONSTRAINT [DF_ClientReportDateRanges_LastModifiedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedBy]          VARCHAR (20) NULL,
    CONSTRAINT [PK_ClientReportDateRanges] PRIMARY KEY CLUSTERED ([ClientReportDateRangeID] ASC)
);

