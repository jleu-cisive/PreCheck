CREATE TABLE [dbo].[ApplFlagStatus] (
    [APNO]           INT      NOT NULL,
    [FlagStatus]     INT      NULL,
    [LastUpdatedUTC] DATETIME NULL,
    CONSTRAINT [PK_ApplFlagStatus] PRIMARY KEY CLUSTERED ([APNO] ASC) WITH (FILLFACTOR = 50)
);

