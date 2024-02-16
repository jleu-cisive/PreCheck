CREATE TABLE [dbo].[ClientAccess_Report] (
    [ClientAccessReportID] INT            IDENTITY (1, 1) NOT NULL,
    [ProcedureName]        VARCHAR (200)  NULL,
    [DisplayName]          VARCHAR (200)  NULL,
    [Description]          VARCHAR (1000) NULL,
    [ParameterNames]       VARCHAR (200)  NULL,
    [ParameterTypes]       VARCHAR (200)  NULL,
    [ParameterDisplay]     VARCHAR (200)  NULL,
    [AllClients]           BIT            NULL,
    CONSTRAINT [PK_ClientAccessReportTest] PRIMARY KEY CLUSTERED ([ClientAccessReportID] ASC) WITH (FILLFACTOR = 50)
);

