CREATE TABLE [dbo].[ClientAccessReportMap] (
    [ClientAccessReportMapID] INT           IDENTITY (1, 1) NOT NULL,
    [ClientAccessReportID]    INT           NOT NULL,
    [CLNO]                    INT           NULL,
    [LastParameters]          VARCHAR (200) NULL,
    CONSTRAINT [PK_ClientAccessReportMap] PRIMARY KEY CLUSTERED ([ClientAccessReportMapID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ClientAccessReportMap_ClientAccessReport] FOREIGN KEY ([ClientAccessReportID]) REFERENCES [dbo].[ClientAccessReport] ([ClientAccessReportID])
);

