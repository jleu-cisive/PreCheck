CREATE TABLE [dbo].[Counties_Group] (
    [CountyGroupID]       INT IDENTITY (1, 1) NOT NULL,
    [CNTY_NO]             INT NOT NULL,
    [refCountyGroupingID] INT NOT NULL,
    [IsActive]            BIT CONSTRAINT [DF_Counties_Group_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Counties_Group] PRIMARY KEY CLUSTERED ([CountyGroupID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_Counties_Group_Counties] FOREIGN KEY ([CNTY_NO]) REFERENCES [dbo].[TblCounties] ([CNTY_NO]),
    CONSTRAINT [FK_Counties_Group_refCountyGroupings] FOREIGN KEY ([refCountyGroupingID]) REFERENCES [dbo].[refCountyGroupings] ([refCountyGroupingID])
);

