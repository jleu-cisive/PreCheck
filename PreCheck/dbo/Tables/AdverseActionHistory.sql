CREATE TABLE [dbo].[AdverseActionHistory] (
    [AdverseActionHistoryID] INT           IDENTITY (1, 1) NOT NULL,
    [AdverseActionID]        INT           NULL,
    [AdverseChangeTypeID]    INT           CONSTRAINT [DF_AdverseActionHistory_AdverseChangeTypeID] DEFAULT (1) NULL,
    [StatusID]               INT           NULL,
    [UserID]                 CHAR (10)     NULL,
    [AdverseContactMethodID] INT           NULL,
    [Comments]               TEXT          NULL,
    [Date]                   DATETIME      NULL,
    [ReportID]               INT           NULL,
    [AppendedToAppl]         BIT           CONSTRAINT [DF_AdverseActionHistory_AppendedToAppl] DEFAULT (0) NOT NULL,
    [Source]                 VARCHAR (100) NULL,
    CONSTRAINT [PK_AdverseActionHistory] PRIMARY KEY CLUSTERED ([AdverseActionHistoryID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IDX_AdverseActionHistory_AdverseActionID_Inc]
    ON [dbo].[AdverseActionHistory]([AdverseActionID] ASC)
    INCLUDE([StatusID], [Date]) WITH (FILLFACTOR = 70);

