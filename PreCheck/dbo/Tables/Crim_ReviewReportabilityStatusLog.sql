CREATE TABLE [dbo].[Crim_ReviewReportabilityStatusLog] (
    [ReviewReportabilityStatusLogID] INT          IDENTITY (1, 1) NOT NULL,
    [CrimID]                         INT          NULL,
    [APNO]                           INT          NOT NULL,
    [County]                         VARCHAR (40) NOT NULL,
    [OldStatus]                      VARCHAR (1)  NULL,
    [NewStatus]                      VARCHAR (1)  NULL,
    [Degree]                         VARCHAR (10) NULL,
    [Createddate]                    DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ReviewReportabilityStatusLogID] PRIMARY KEY CLUSTERED ([ReviewReportabilityStatusLogID] ASC) WITH (FILLFACTOR = 90)
);

