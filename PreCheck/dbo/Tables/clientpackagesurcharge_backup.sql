CREATE TABLE [dbo].[clientpackagesurcharge_backup] (
    [ClientPackageSurchargeID] INT           IDENTITY (1, 1) NOT NULL,
    [Description]              VARCHAR (100) NOT NULL,
    [Amount]                   SMALLMONEY    NOT NULL,
    [ClientPackagesID]         INT           NOT NULL
) ON [PRIMARY];

