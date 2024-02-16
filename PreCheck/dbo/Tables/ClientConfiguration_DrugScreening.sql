CREATE TABLE [dbo].[ClientConfiguration_DrugScreening] (
    [ClientConfiguration_DrugScreeningID] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                                SMALLINT     NOT NULL,
    [PackageID]                           INT          NULL,
    [Location]                            VARCHAR (50) NOT NULL,
    [ProdCat]                             VARCHAR (50) CONSTRAINT [DF_ClientConfiguration_DrugScreening_ProdCat] DEFAULT ('urine') NOT NULL,
    [ProdClass]                           VARCHAR (50) CONSTRAINT [DF_ClientConfiguration_DrugScreening_ProdClass] DEFAULT ('drugtest') NOT NULL,
    [SpecType]                            VARCHAR (50) NOT NULL,
    [Customer]                            VARCHAR (10) NULL,
    CONSTRAINT [PK_ClientConfiguration_DrugScreening] PRIMARY KEY CLUSTERED ([ClientConfiguration_DrugScreeningID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ClientConfiguration_DrugScreening_Client] FOREIGN KEY ([CLNO]) REFERENCES [dbo].[Client] ([CLNO])
);

