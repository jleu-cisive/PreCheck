CREATE TABLE [dbo].[StateBoardDataEntry] (
    [StateBoardDataEntryID]       INT            IDENTITY (1, 1) NOT NULL,
    [FirstName]                   VARCHAR (50)   NULL,
    [LastName]                    VARCHAR (50)   NULL,
    [LicenseNumber]               VARCHAR (50)   NOT NULL,
    [LicenseType]                 VARCHAR (50)   NULL,
    [State]                       VARCHAR (50)   NULL,
    [ActionDate]                  DATETIME       NOT NULL,
    [Description]                 VARCHAR (8000) NULL,
    [UserID]                      VARCHAR (20)   NULL,
    [StateBoardDisciplinaryRunID] INT            NULL,
    [DateEntered]                 DATETIME       CONSTRAINT [DF_StateBoardDataEntry_DateEntered] DEFAULT (getdate()) NULL,
    [NoBoardAction]               BIT            NULL,
    [ReportDate]                  VARCHAR (20)   NULL,
    [BatchDate]                   DATETIME       NULL,
    CONSTRAINT [PK_StateBoardDataEntry] PRIMARY KEY CLUSTERED ([StateBoardDataEntryID] ASC) WITH (FILLFACTOR = 50)
);

