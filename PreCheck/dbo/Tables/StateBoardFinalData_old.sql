CREATE TABLE [dbo].[StateBoardFinalData_old] (
    [StateBoardFinalDataID] INT          IDENTITY (1, 1) NOT NULL,
    [FirstName]             VARCHAR (50) NULL,
    [LastName]              VARCHAR (50) NULL,
    [LicenseNumber]         INT          NOT NULL,
    [LicenseType]           VARCHAR (50) NULL,
    [State]                 VARCHAR (50) NULL,
    [ActionDate]            DATETIME     NULL,
    [Description]           VARCHAR (50) NULL,
    [StateBoardSourceID]    INT          NULL,
    CONSTRAINT [PK_StateBoardFinalData1] PRIMARY KEY CLUSTERED ([StateBoardFinalDataID] ASC) WITH (FILLFACTOR = 50)
);

