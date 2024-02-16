CREATE TABLE [dbo].[RefConfigurationsLog] (
    [LogID]      INT            IDENTITY (1, 1) NOT NULL,
    [UserID]     VARCHAR (50)   NULL,
    [Keyname]    VARCHAR (50)   NULL,
    [OldValue]   VARCHAR (1000) NULL,
    [NewValue]   VARCHAR (1000) NULL,
    [ChangeDate] DATETIME       CONSTRAINT [DF_RefConfigurationsLog_ChangeDate] DEFAULT (getdate()) NULL,
    [Tablename]  VARCHAR (50)   NULL,
    [Type]       VARCHAR (50)   NULL,
    [CLNO]       INT            NULL,
    CONSTRAINT [PK_RefConfigurationsLog] PRIMARY KEY CLUSTERED ([LogID] ASC) WITH (FILLFACTOR = 50)
);

