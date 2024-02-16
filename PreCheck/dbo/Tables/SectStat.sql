CREATE TABLE [dbo].[SectStat] (
    [Code]                       CHAR (1)     NOT NULL,
    [Description]                VARCHAR (25) NULL,
    [onlinedescription]          VARCHAR (25) NULL,
    [LevelOfImportance]          INT          NULL,
    [Department]                 VARCHAR (10) NULL,
    [IsActive]                   BIT          DEFAULT ((0)) NULL,
    [IsVerifyStatus]             BIT          DEFAULT ((0)) NULL,
    [ReportedStatus_Integration] VARCHAR (15) NULL,
    [IsClear]                    BIT          NULL,
    [CreatedDate]                DATETIME     NULL,
    [CreatedBy]                  VARCHAR (50) NULL,
    [ModifiedDate]               DATETIME     NULL,
    [ModifiedBy]                 VARCHAR (50) NULL,
    [OverallStatus]              INT          NULL,
    CONSTRAINT [PK_SectStat] PRIMARY KEY CLUSTERED ([Code] ASC) WITH (FILLFACTOR = 50)
);

