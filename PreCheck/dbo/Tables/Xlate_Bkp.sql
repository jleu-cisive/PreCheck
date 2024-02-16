CREATE TABLE [dbo].[Xlate_Bkp] (
    [XlateID]     INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]        INT          NULL,
    [TableOut]    VARCHAR (50) NULL,
    [ColumnOut]   VARCHAR (50) NULL,
    [PositionOut] INT          NULL,
    [Length]      INT          NULL,
    [TableIn]     VARCHAR (50) NULL,
    [ColumnIn]    VARCHAR (50) NULL,
    [PositionIn]  INT          NULL,
    CONSTRAINT [PK_Xlate_bkp] PRIMARY KEY CLUSTERED ([XlateID] ASC) WITH (FILLFACTOR = 50)
);

