CREATE TABLE [CARCOGROUP.COM\AKRai].[clientpackages_bkp17022023] (
    [ClientPackagesID]          INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                      SMALLINT      NOT NULL,
    [PackageID]                 INT           NOT NULL,
    [Rate]                      SMALLMONEY    NULL,
    [ClientPackageDesc]         VARCHAR (100) NULL,
    [ClientPackageCode]         VARCHAR (50)  NULL,
    [IsActive]                  BIT           NOT NULL,
    [BusinessServiceBehaviorId] INT           NULL,
    [CreateDate]                DATETIME      NULL,
    [CreateBy]                  VARCHAR (50)  NULL,
    [ModifyDate]                DATETIME      NULL,
    [ModifyBy]                  VARCHAR (50)  NULL,
    [ZipCrimClientPackageID]    VARCHAR (6)   NULL
);

