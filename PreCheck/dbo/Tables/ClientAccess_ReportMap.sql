CREATE TABLE [dbo].[ClientAccess_ReportMap] (
    [ClientAccessReportMapID] INT           IDENTITY (1, 1) NOT NULL,
    [ClientAccessReportID]    INT           NOT NULL,
    [CLNO]                    INT           NULL,
    [LastParameters]          VARCHAR (200) NULL,
    CONSTRAINT [PK_ClientAccessReportMapTest] PRIMARY KEY CLUSTERED ([ClientAccessReportMapID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ClientAccessReportMapTest_ClientAccessReportTest] FOREIGN KEY ([ClientAccessReportID]) REFERENCES [dbo].[ClientAccess_Report] ([ClientAccessReportID])
);

