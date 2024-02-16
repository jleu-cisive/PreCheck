CREATE TABLE [dbo].[EmplAutoFaxUpdates] (
    [UpdateID]            INT           IDENTITY (1, 1) NOT NULL,
    [FaxID]               INT           NOT NULL,
    [UserName]            VARCHAR (25)  NULL,
    [CreatedDate]         DATETIME      NULL,
    [Note]                VARCHAR (255) NULL,
    [CurrentExpectedDate] VARCHAR (30)  NULL,
    CONSTRAINT [PK_EmplAutoFaxUpdates] PRIMARY KEY CLUSTERED ([UpdateID] ASC) WITH (FILLFACTOR = 50)
);

