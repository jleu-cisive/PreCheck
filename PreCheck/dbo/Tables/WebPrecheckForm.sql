CREATE TABLE [dbo].[WebPrecheckForm] (
    [WebPrecheckFormID] INT          IDENTITY (1, 1) NOT NULL,
    [Form]              VARCHAR (50) NULL,
    [ForID]             INT          NULL,
    [FilePath]          VARCHAR (50) NULL,
    [Isactive]          BIT          CONSTRAINT [DF_WebPrecheckForm_Isactive] DEFAULT (1) NULL
) ON [PRIMARY];

