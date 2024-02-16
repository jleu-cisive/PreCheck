CREATE TABLE [dbo].[Crim_ReviewReportabilityLog] (
    [ReviewReportabilityLogID] INT          IDENTITY (1, 1) NOT NULL,
    [CrimID]                   INT          NULL,
    [APNO]                     INT          NOT NULL,
    [County]                   VARCHAR (40) NOT NULL,
    [Clear]                    VARCHAR (1)  NULL,
    [Degree]                   VARCHAR (10) NULL,
    [Disp_Date]                DATETIME     NULL,
    [Createddate]              DATETIME     CONSTRAINT [Createddate_value] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ReviewReportabilityLogID] PRIMARY KEY CLUSTERED ([ReviewReportabilityLogID] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_ReviewReportabilityLog_CrimID]
    ON [dbo].[Crim_ReviewReportabilityLog]([CrimID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_Crim_ReviewReportabilityLog_APNO]
    ON [dbo].[Crim_ReviewReportabilityLog]([APNO] ASC);

