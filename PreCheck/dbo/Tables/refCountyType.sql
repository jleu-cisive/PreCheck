CREATE TABLE [dbo].[refCountyType] (
    [refCountyTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [CountyType]      VARCHAR (50) NOT NULL,
    [Description]     VARCHAR (50) NOT NULL,
    [IsActive]        BIT          CONSTRAINT [DF_refCountyCategory_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_refCountyCategory] PRIMARY KEY CLUSTERED ([refCountyTypeID] ASC) WITH (FILLFACTOR = 50)
);

