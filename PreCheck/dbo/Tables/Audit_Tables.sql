CREATE TABLE [dbo].[Audit_Tables] (
    [AuditID]      INT           IDENTITY (1, 1) NOT NULL,
    [AuditSchema]  VARCHAR (255) NOT NULL,
    [AuditTable]   VARCHAR (255) NOT NULL,
    [AuditColumns] VARCHAR (255) NOT NULL,
    [ActiveFlag]   BIT           DEFAULT ((1)) NOT NULL,
    [TriggerFlag]  BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([AuditID] ASC) WITH (FILLFACTOR = 70)
);

