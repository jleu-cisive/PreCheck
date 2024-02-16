CREATE TABLE [dbo].[I9LocationMapping] (
    [I9LocationMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [ClientId]            INT           NULL,
    [ExternalLocationId]  VARCHAR (100) NULL,
    [InternalLocationId]  VARCHAR (100) NULL
);

