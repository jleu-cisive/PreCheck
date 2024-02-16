CREATE TABLE [dbo].[Application$] (
    [ClientID]              FLOAT (53)     NULL,
    [CAM]                   NVARCHAR (255) NULL,
    [ApplicantInvestigator] NVARCHAR (255) NULL,
    [PackageID]             FLOAT (53)     NULL,
    [AttentionTo]           NVARCHAR (255) NULL,
    [LastName]              NVARCHAR (255) NULL,
    [FirstName]             NVARCHAR (255) NULL,
    [SSN]                   NVARCHAR (255) NULL,
    [DOB]                   NVARCHAR (255) NULL,
    [School]                NVARCHAR (255) NULL,
    [City]                  NVARCHAR (255) NULL,
    [State]                 NVARCHAR (255) NULL,
    [IsProcessed]           BIT            CONSTRAINT [DF_Application$_IsProcessed] DEFAULT ((0)) NOT NULL
);

