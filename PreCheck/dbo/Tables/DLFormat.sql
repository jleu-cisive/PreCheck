CREATE TABLE [dbo].[DLFormat] (
    [DLFormatID]  INT          IDENTITY (1, 1) NOT NULL,
    [State]       VARCHAR (2)  NOT NULL,
    [Mask]        VARCHAR (50) NOT NULL,
    [RegExMask]   VARCHAR (50) NULL,
    [DisplayMask] VARCHAR (50) NULL,
    CONSTRAINT [PK_DLFormat] PRIMARY KEY CLUSTERED ([DLFormatID] ASC) WITH (FILLFACTOR = 50)
);

