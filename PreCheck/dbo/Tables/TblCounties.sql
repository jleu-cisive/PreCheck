CREATE TABLE [dbo].[TblCounties] (
    [CNTY_NO]           INT           IDENTITY (1, 1) NOT NULL,
    [County]            VARCHAR (40)  NOT NULL,
    [Crim_Source]       VARCHAR (2)   NULL,
    [Crim_Phone]        VARCHAR (20)  NULL,
    [Crim_Fax]          VARCHAR (20)  NULL,
    [Crim_Addr]         VARCHAR (255) NULL,
    [Crim_Comment]      VARCHAR (20)  NULL,
    [Crim_DefaultRate]  SMALLMONEY    CONSTRAINT [DF_Counties_Crim_DefaultRate] DEFAULT (0) NOT NULL,
    [Civ_Source]        VARCHAR (2)   NULL,
    [Civ_Phone]         VARCHAR (20)  NULL,
    [Civ_Fax]           VARCHAR (20)  NULL,
    [Civ_Addr]          VARCHAR (255) NULL,
    [Civ_Comment]       VARCHAR (20)  NULL,
    [State]             VARCHAR (25)  NULL,
    [A_County]          VARCHAR (25)  NULL,
    [Country]           VARCHAR (25)  NULL,
    [PassThroughCharge] SMALLMONEY    CONSTRAINT [DF_Counties_PassThroughCharge] DEFAULT ((0)) NULL,
    [isStatewide]       BIT           DEFAULT ((0)) NULL,
    [FIPS]              VARCHAR (10)  NULL,
    [refCountyTypeID]   INT           NULL,
    [IsActive]          BIT           CONSTRAINT [DF__TblCounti__IsAct__42E51C5A] DEFAULT ((1)) NOT NULL,
    [CreateDate]        DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifyDate]        DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         DATETIME      NULL,
    [ModifiedBy]        DATETIME      NULL,
    CONSTRAINT [PK_Counties] PRIMARY KEY NONCLUSTERED ([CNTY_NO] ASC) WITH (FILLFACTOR = 50) ON [FG_DATA],
    CONSTRAINT [FK_Counties_refCountyType] FOREIGN KEY ([refCountyTypeID]) REFERENCES [dbo].[refCountyType] ([refCountyTypeID])
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_State_acounty]
    ON [dbo].[TblCounties]([State] ASC, [A_County] ASC)
    INCLUDE([CNTY_NO]) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IX_Counties]
    ON [dbo].[TblCounties]([County] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_Counties_FIPS]
    ON [dbo].[TblCounties]([FIPS] ASC) WITH (FILLFACTOR = 70)
    ON [PRIMARY];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Added by Trong (12/28/06). This field is used to calculate the charges passed on to the client if a record was ordered for a specific county.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TblCounties', @level2type = N'COLUMN', @level2name = N'PassThroughCharge';

