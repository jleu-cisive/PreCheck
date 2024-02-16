CREATE TABLE [dbo].[ApplCounties] (
    [Apno]                INT          NOT NULL,
    [SourceID]            INT          NOT NULL,
    [County]              VARCHAR (50) NULL,
    [State]               VARCHAR (2)  NULL,
    [IsStatewide]         BIT          NULL,
    [CNTY_NUM]            INT          NULL,
    [CNTY_NUMToOrder]     INT          NULL,
    [CountyCount]         INT          NULL,
    [AddedOn]             DATETIME     CONSTRAINT [DF_ApplCounties_AddedOn] DEFAULT (getdate()) NOT NULL,
    [SourceIdntyColValue] INT          NULL,
    [IsActive]            BIT          CONSTRAINT [DF_applcounties_isactive] DEFAULT ((1)) NOT NULL,
    [ApplCountiesID]      INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_ApplCounties] PRIMARY KEY CLUSTERED ([ApplCountiesID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ApplCounties_Appl] FOREIGN KEY ([Apno]) REFERENCES [dbo].[Appl] ([APNO]),
    CONSTRAINT [FK_ApplCounties_BRSources] FOREIGN KEY ([SourceID]) REFERENCES [dbo].[BRSources] ([SourceID])
);


GO
CREATE NONCLUSTERED INDEX [ApplCounties_Apno_SourceID_IsActive]
    ON [dbo].[ApplCounties]([Apno] ASC, [SourceID] ASC, [IsActive] ASC) WITH (FILLFACTOR = 50);

