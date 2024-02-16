CREATE TABLE [dbo].[WorkNumberLogging] (
    [WorkNumberLoggingID] INT          IDENTITY (1, 1) NOT NULL,
    [Apno]                INT          NULL,
    [EmplID]              INT          NULL,
    [UserID]              VARCHAR (20) NULL,
    [XMLData]             TEXT         NULL,
    [ContainsError]       BIT          CONSTRAINT [DF_WorkNumberLogging_ContainsError] DEFAULT ((0)) NOT NULL,
    [CreatedDate]         DATETIME     NULL,
    CONSTRAINT [PK_WorkNumberLogging] PRIMARY KEY CLUSTERED ([WorkNumberLoggingID] ASC)
) TEXTIMAGE_ON [PRIMARY];

