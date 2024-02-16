CREATE TABLE [dbo].[Feb_Sanction_FCRA] (
    [Cert #]              NVARCHAR (255) NULL,
    [Client]              NVARCHAR (255) NULL,
    [Group Name]          NVARCHAR (255) NULL,
    [Facility Name]       NVARCHAR (255) NULL,
    [Order Total]         FLOAT (53)     NULL,
    [Client #]            FLOAT (53)     NULL,
    [Order Date]          DATETIME       NULL,
    [Investigator]        NVARCHAR (255) NULL,
    [Assigned/ Processed] DATETIME       NULL,
    [Completed]           DATETIME       NULL,
    [Report Date]         DATETIME       NULL,
    [ Returned]           DATETIME       NULL,
    [Total Count]         FLOAT (53)     NULL,
    [Rate]                MONEY          NULL,
    [Total Charge]        MONEY          NULL,
    [Package]             NVARCHAR (255) NULL,
    [Comments]            NVARCHAR (255) NULL,
    [Frequency ]          NVARCHAR (255) NULL
);

