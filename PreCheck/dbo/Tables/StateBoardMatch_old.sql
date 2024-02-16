CREATE TABLE [dbo].[StateBoardMatch_old] (
    [StateBoardMatchID]           INT           IDENTITY (1, 1) NOT NULL,
    [EmployeeFirstName]           VARCHAR (50)  NULL,
    [EmployeeMiddleName]          VARCHAR (50)  NULL,
    [EmployeeLastName]            VARCHAR (50)  NULL,
    [EmployeeSSN]                 CHAR (11)     NULL,
    [CLNO]                        INT           NULL,
    [StateBoardLicenseType]       VARCHAR (50)  NULL,
    [StateBoardLicenseNumber]     VARCHAR (50)  NULL,
    [StateBoardLicenseState]      VARCHAR (50)  NULL,
    [IsMatch]                     BIT           NULL,
    [NoMatched]                   BIT           NULL,
    [InsertDate]                  DATETIME      NULL,
    [Emailed]                     BIT           NULL,
    [EmailDate]                   DATETIME      NULL,
    [CredentCheckBis]             VARCHAR (3)   NULL,
    [Apno]                        INT           NULL,
    [Apdate]                      DATETIME      NULL,
    [StateBoardDisciplinaryRunID] INT           NULL,
    [Notes]                       VARCHAR (200) NULL,
    [SantionType]                 VARCHAR (100) NULL,
    CONSTRAINT [PK_StateBoardMatch1] PRIMARY KEY CLUSTERED ([StateBoardMatchID] ASC) WITH (FILLFACTOR = 50)
);

