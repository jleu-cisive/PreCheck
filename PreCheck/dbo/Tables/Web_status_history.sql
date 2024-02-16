CREATE TABLE [dbo].[Web_status_history] (
    [web_statusid]   INT           IDENTITY (1, 1) NOT NULL,
    [history_appno]  VARCHAR (50)  NULL,
    [history_date]   SMALLDATETIME NULL,
    [history_status] VARCHAR (100) NULL,
    [emplid]         VARCHAR (50)  NULL,
    CONSTRAINT [PK_Web_status_history] PRIMARY KEY CLUSTERED ([web_statusid] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_Web_status_history]
    ON [dbo].[Web_status_history]([emplid] ASC, [history_appno] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

