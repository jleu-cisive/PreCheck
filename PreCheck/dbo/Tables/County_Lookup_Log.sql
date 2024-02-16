CREATE TABLE [dbo].[County_Lookup_Log] (
    [LogID]          INT           IDENTITY (1, 1) NOT NULL,
    [City]           VARCHAR (20)  NULL,
    [Sate]           VARCHAR (2)   NULL,
    [Zip]            VARCHAR (10)  NULL,
    [County_Org]     NVARCHAR (50) NULL,
    [CNTY_No]        INT           NULL,
    [isStateWide]    BIT           NULL,
    [County_Return]  NVARCHAR (50) NULL,
    [State_Return]   VARCHAR (2)   NULL,
    [CNTY_NoToOrder] INT           NULL,
    CONSTRAINT [PK_County_Lookup_Log] PRIMARY KEY CLUSTERED ([LogID] ASC) WITH (FILLFACTOR = 50)
);

