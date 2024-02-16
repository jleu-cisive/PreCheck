CREATE TABLE [dbo].[PackageComponent] (
    [PackageComponentID]     INT           IDENTITY (1, 1) NOT NULL,
    [Description]            VARCHAR (255) NULL,
    [DefaultRate]            SMALLMONEY    NULL,
    [DefaultRescreeningRate] SMALLMONEY    NULL,
    [IsActive]               BIT           CONSTRAINT [DF_PackageComponent_IsActive] DEFAULT ((1)) NOT NULL,
    [refAlertTypeID]         INT           NULL,
    CONSTRAINT [PK_PackageComponent] PRIMARY KEY CLUSTERED ([PackageComponentID] ASC) WITH (FILLFACTOR = 50)
);

