CREATE TABLE [dbo].[refPackageType] (
    [refPackageTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [Description]      VARCHAR (50) NULL,
    CONSTRAINT [PK_refPackageType] PRIMARY KEY CLUSTERED ([refPackageTypeID] ASC) WITH (FILLFACTOR = 50)
);

