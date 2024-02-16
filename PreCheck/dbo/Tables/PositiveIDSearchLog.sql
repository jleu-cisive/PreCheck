CREATE TABLE [dbo].[PositiveIDSearchLog] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [ApNo]       INT           NULL,
    [SSN]        VARCHAR (11)  NULL,
    [ClNo]       INT           NULL,
    [Requester]  NVARCHAR (50) NULL,
    [SearchDate] DATETIME      CONSTRAINT [DF_PositiveIDSearchLog_SearchDate] DEFAULT (getdate()) NOT NULL,
    [ResponseID] INT           NOT NULL,
    CONSTRAINT [PK_PositiveIDSearchLog] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_PositiveIDSearchLog_PositiveIDResponseLog] FOREIGN KEY ([ResponseID]) REFERENCES [dbo].[PositiveIDResponseLog] ([ResponseID])
);

