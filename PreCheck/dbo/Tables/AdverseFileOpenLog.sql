CREATE TABLE [dbo].[AdverseFileOpenLog] (
    [AdverseFileOpenLogID] INT           IDENTITY (1, 1) NOT NULL,
    [AdverseActionID]      INT           NULL,
    [Type]                 VARCHAR (50)  NULL,
    [TypeID]               VARCHAR (50)  NULL,
    [TypeName]             VARCHAR (100) NULL,
    [UserID]               CHAR (10)     NULL,
    [Dispute]              BIT           CONSTRAINT [DF_AdverseFileOpenLog_Dispute] DEFAULT (0) NULL,
    [Amended]              BIT           CONSTRAINT [DF_AdverseFileOpenLog_Amended] DEFAULT (0) NULL,
    [Confirmed]            BIT           CONSTRAINT [DF_AdverseFileOpenLog_Confirmed] DEFAULT (0) NULL,
    [Complete]             BIT           CONSTRAINT [DF_AdverseFileOpenLog_Complete] DEFAULT (0) NULL,
    [Date]                 DATETIME      CONSTRAINT [DF_AdverseFileOpenLog_Date] DEFAULT (getdate()) NULL
) ON [PRIMARY];

