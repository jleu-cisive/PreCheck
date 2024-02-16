CREATE TABLE [Stage].[SalesHistory] (
    [OrderDate]         DATE          NOT NULL,
    [ClientId]          INT           NOT NULL,
    [EnteredVia]        VARCHAR (10)  NULL,
    [PackageId]         INT           NULL,
    [PackageName]       VARCHAR (200) NULL,
    [PackagePrice]      MONEY         NULL,
    [OrderReceiveCount] INT           NULL,
    [OrderCloseCount]   INT           NULL,
    [OrderInviteCount]  INT           NULL,
    [Sales]             MONEY         NULL
);

