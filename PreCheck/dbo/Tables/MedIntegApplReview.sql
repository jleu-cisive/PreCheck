CREATE TABLE [dbo].[MedIntegApplReview] (
    [MedIntegApplReviewID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                 INT          NULL,
    [UserName]             VARCHAR (25) NULL,
    [CreatedDate]          DATETIME     NULL,
    [Status]               VARCHAR (25) NULL,
    [ReportText]           TEXT         NULL,
    [Record]               TEXT         NULL,
    [Completed]            BIT          NULL,
    [ClearedBy]            VARCHAR (25) NULL,
    CONSTRAINT [PK_MedIntegApplReview] PRIMARY KEY CLUSTERED ([MedIntegApplReviewID] ASC)
) TEXTIMAGE_ON [PRIMARY];

