CREATE TABLE [dbo].[Crimsectstat] (
    [crimsectid]                 INT          IDENTITY (1, 1) NOT NULL,
    [crimsect]                   VARCHAR (2)  NULL,
    [crimdescription]            VARCHAR (50) NULL,
    [LevelOfImportance]          INT          NULL,
    [ReportedStatus_Integration] VARCHAR (15) NULL,
    [IsClear]                    BIT          NULL,
    [OverallStatus]              INT          NULL
) ON [PRIMARY];

