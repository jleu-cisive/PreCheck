CREATE TABLE [dbo].[Websectstat] (
    [code]        INT          NOT NULL,
    [description] VARCHAR (70) NULL,
    [Empl]        BIT          DEFAULT ((0)) NOT NULL,
    [Educat]      BIT          DEFAULT ((0)) NOT NULL,
    [PersRef]     BIT          DEFAULT ((0)) NOT NULL,
    [ProfLic]     BIT          DEFAULT ((0)) NOT NULL,
    [Crim]        BIT          DEFAULT ((0)) NOT NULL,
    [DL]          BIT          DEFAULT ((0)) NOT NULL,
    [MedInteg]    BIT          DEFAULT ((0)) NOT NULL,
    [Credit]      BIT          DEFAULT ((0)) NOT NULL,
    [PositiveID]  BIT          DEFAULT ((0)) NOT NULL,
    [Purpose]     VARCHAR (50) NULL,
    [IsActive]    BIT          CONSTRAINT [DF_Websectstat_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Websectstat] PRIMARY KEY CLUSTERED ([code] ASC) WITH (FILLFACTOR = 90)
);

