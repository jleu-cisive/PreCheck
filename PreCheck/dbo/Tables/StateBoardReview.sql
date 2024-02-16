CREATE TABLE [dbo].[StateBoardReview] (
    [StateBoardReviewID]          INT            IDENTITY (1, 1) NOT NULL,
    [FirstName]                   VARCHAR (50)   NULL,
    [LastName]                    VARCHAR (50)   NULL,
    [LicenseNumber]               VARCHAR (50)   NOT NULL,
    [LicenseType]                 VARCHAR (50)   NULL,
    [State]                       VARCHAR (50)   NULL,
    [ActionDate]                  DATETIME       NULL,
    [ReportDate]                  VARCHAR (20)   NULL,
    [BatchDate]                   DATETIME       NULL,
    [Description]                 VARCHAR (8000) NULL,
    [NoBoardAction]               BIT            NOT NULL,
    [StateBoardDisciplinaryRunID] INT            NULL,
    [StateBoardSourceID]          INT            NULL,
    CONSTRAINT [PK_StateBoardReview] PRIMARY KEY CLUSTERED ([StateBoardReviewID] ASC) WITH (FILLFACTOR = 50)
);

