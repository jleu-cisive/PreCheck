CREATE TABLE [dbo].[StudentCheckPackages] (
    [ClientPackagesID]         INT            NULL,
    [CLNO]                     INT            NULL,
    [PackageID]                INT            NULL,
    [ClientPackageDesc]        NVARCHAR (255) NULL,
    [ClientPackageCode]        NVARCHAR (255) NULL,
    [IsActive]                 BIT            NULL,
    [PackageID1]               INT            NULL,
    [Default Rate]             FLOAT (53)     NULL,
    [Client Rate]              FLOAT (53)     NULL,
    [PackageType]              NVARCHAR (255) NULL,
    [background rate]          FLOAT (53)     NULL,
    [DrugTest Rate]            FLOAT (53)     NULL,
    [Immunization Rate]        NVARCHAR (255) NULL,
    [background client Rate]   FLOAT (53)     NULL,
    [DrugTest client Rate ]    FLOAT (53)     NULL,
    [Immunization Client Rate] FLOAT (53)     NULL,
    [PackageDesc]              NVARCHAR (255) NULL,
    [Background Name]          NVARCHAR (255) NULL,
    [Drug Test Name]           NVARCHAR (255) NULL,
    [Imm Name]                 NVARCHAR (255) NULL,
    [Combo Services required]  NVARCHAR (255) NULL
);

