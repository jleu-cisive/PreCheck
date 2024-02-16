CREATE TABLE [dbo].[ApplAddress] (
    [ApplAddressID] INT           IDENTITY (1, 1) NOT NULL,
    [APNO]          INT           NULL,
    [Address]       VARCHAR (200) NULL,
    [City]          VARCHAR (50)  NULL,
    [State]         VARCHAR (20)  NULL,
    [Zip]           VARCHAR (10)  NULL,
    [Country]       VARCHAR (50)  NULL,
    [DateStart]     DATETIME      NULL,
    [DateEnd]       DATETIME      NULL,
    [Source]        VARCHAR (20)  NULL,
    [CLNO]          INT           NULL,
    [SSN]           VARCHAR (20)  NULL,
    [County]        VARCHAR (50)  NULL,
    CONSTRAINT [PK_ApplAddress] PRIMARY KEY CLUSTERED ([ApplAddressID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ApplAddress_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO])
);


GO
CREATE NONCLUSTERED INDEX [IDX_ApplAddress_APNO]
    ON [dbo].[ApplAddress]([APNO] ASC)
    INCLUDE([ApplAddressID], [City], [State], [Zip], [DateStart], [DateEnd], [SSN]) WITH (FILLFACTOR = 70);

