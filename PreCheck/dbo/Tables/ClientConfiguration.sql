CREATE TABLE [dbo].[ClientConfiguration] (
    [CLNO]             INT            NOT NULL,
    [ConfigurationKey] VARCHAR (50)   NOT NULL,
    [Value]            VARCHAR (1000) NOT NULL,
    [ApplyToEveryone]  BIT            CONSTRAINT [DF_ClientConfiguration_ApplyToEveryone] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ClientConfiguration] PRIMARY KEY CLUSTERED ([CLNO] ASC, [ConfigurationKey] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_ClientConfiguration_Value]
    ON [dbo].[ClientConfiguration]([ConfigurationKey] ASC, [Value] ASC)
    INCLUDE([CLNO]) WITH (FILLFACTOR = 50);

