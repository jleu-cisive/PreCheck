CREATE TABLE [dbo].[refCountyGroupings] (
    [refCountyGroupingID] INT          IDENTITY (1, 1) NOT NULL,
    [CountyGrouping]      VARCHAR (20) NOT NULL,
    [Description]         VARCHAR (50) NOT NULL,
    [IsActive]            BIT          CONSTRAINT [DF_refCountyGroupings_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_refCountyGroupings] PRIMARY KEY CLUSTERED ([refCountyGroupingID] ASC) WITH (FILLFACTOR = 50)
);

