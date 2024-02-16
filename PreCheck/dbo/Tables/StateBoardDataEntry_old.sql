CREATE TABLE [dbo].[StateBoardDataEntry_old] (
    [StateBoardDataEntryID] INT          IDENTITY (1, 1) NOT NULL,
    [FirstName]             VARCHAR (50) NULL,
    [LastName]              VARCHAR (50) NULL,
    [LicenseNumber]         VARCHAR (50) NOT NULL,
    [LicenseType]           VARCHAR (50) NULL,
    [State]                 VARCHAR (50) NULL,
    [ActionDate]            DATETIME     NULL,
    [Description]           VARCHAR (50) NULL,
    [UserID]                VARCHAR (20) NULL,
    [StateBoardSourceID]    INT          NULL,
    CONSTRAINT [PK_StateBoardDataEntry_1] PRIMARY KEY CLUSTERED ([StateBoardDataEntryID] ASC) WITH (FILLFACTOR = 50)
);

