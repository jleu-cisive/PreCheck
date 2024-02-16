CREATE TABLE [dbo].[ClientAccessReportLog] (
    [ClientAccessReportLogID] INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                    INT           NULL,
    [UserID]                  VARCHAR (50)  NULL,
    [ClientAccessReportID]    INT           NULL,
    [Params]                  VARCHAR (200) NULL,
    [Logdate]                 DATETIME      NULL,
    CONSTRAINT [PK_ClientAccessReportLog] PRIMARY KEY CLUSTERED ([ClientAccessReportLogID] ASC) WITH (FILLFACTOR = 50)
);

