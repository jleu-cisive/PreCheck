CREATE TABLE [dbo].[BisReportsList] (
    [BisReportsListID]  INT           IDENTITY (1, 1) NOT NULL,
    [ReportsDisplay]    VARCHAR (100) NULL,
    [ReportName]        VARCHAR (50)  NULL,
    [ReportDescription] VARCHAR (50)  NULL,
    [CsrShow]           BIT           NULL,
    [InvestigatorShow]  BIT           NULL,
    [ClientListShow]    BIT           NULL,
    [DtStartDateShow]   BIT           NULL,
    [DtEndDateShow]     BIT           NULL,
    [ResearchersShow]   BIT           NULL,
    [CountyListShow]    BIT           NULL,
    [Active]            BIT           NULL,
    [ReportPath]        VARCHAR (50)  NULL,
    [ReportParameters]  VARCHAR (100) NULL,
    [FormParameters]    VARCHAR (100) NULL,
    [CrimTab]           BIT           NULL,
    [PrecheckTab]       BIT           NULL,
    CONSTRAINT [PK_BisReportsList] PRIMARY KEY CLUSTERED ([BisReportsListID] ASC) WITH (FILLFACTOR = 50)
);

