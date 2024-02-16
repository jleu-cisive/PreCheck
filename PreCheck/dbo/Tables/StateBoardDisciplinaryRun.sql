CREATE TABLE [dbo].[StateBoardDisciplinaryRun] (
    [StateBoardDisciplinaryRunID] INT          IDENTITY (1, 1) NOT NULL,
    [StateBoardSourceID]          INT          NOT NULL,
    [StartedDate]                 DATETIME     NULL,
    [CompletedDate]               DATETIME     NULL,
    [ReportDate]                  VARCHAR (20) NULL,
    [BatchDate]                   DATETIME     NULL,
    [UserA]                       VARCHAR (20) NULL,
    [DateStartedA]                DATETIME     NULL,
    [DateCompletedA]              DATETIME     NULL,
    [UserB]                       VARCHAR (20) NULL,
    [DateStartedB]                DATETIME     NULL,
    [DateCompletedB]              DATETIME     NULL,
    [NoBoardAction]               BIT          CONSTRAINT [DF_StateBoardDisciplinaryRun_NoBoardAction] DEFAULT ((0)) NOT NULL,
    [ReviewerUserID]              VARCHAR (20) NULL,
    [TotalEnteredA]               INT          NULL,
    [TotalEnteredB]               INT          NULL,
    [TotalMatches]                INT          NULL,
    [TotalMisMatchesA]            INT          NULL,
    [TotalMisMatchesB]            INT          NULL,
    CONSTRAINT [PK_StateBoardDisciplinaryRun] PRIMARY KEY CLUSTERED ([StateBoardDisciplinaryRunID] ASC) WITH (FILLFACTOR = 50)
);

