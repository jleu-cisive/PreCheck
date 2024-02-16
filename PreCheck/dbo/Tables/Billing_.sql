CREATE TABLE [dbo].[Billing$] (
    [Client ID]           FLOAT (53)     NULL,
    [SSN]                 NVARCHAR (255) NULL,
    [Billing Description] NVARCHAR (255) NULL,
    [Billing Type]        NVARCHAR (255) NULL,
    [Billing Amount]      MONEY          NULL,
    [schoolname]          VARCHAR (1000) NULL,
    [Isprocessed]         BIT            CONSTRAINT [DF_Billing$_Isprocessed] DEFAULT ((0)) NULL
);

