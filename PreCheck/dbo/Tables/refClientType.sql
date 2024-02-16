CREATE TABLE [dbo].[refClientType] (
    [ClientTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [ClientType]   VARCHAR (50) NOT NULL,
    [IsActive]     BIT          NOT NULL,
    CONSTRAINT [PK_refClientType] PRIMARY KEY CLUSTERED ([ClientTypeID] ASC) WITH (FILLFACTOR = 50)
);

