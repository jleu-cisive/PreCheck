CREATE TABLE [dbo].[BrowserHistory] (
    [AppBrowserID] INT           IDENTITY (1, 1) NOT NULL,
    [AppName]      VARCHAR (50)  NULL,
    [Browser]      VARCHAR (200) NULL,
    [startDate]    DATETIME      NULL,
    [EndDate]      DATETIME      NULL,
    CONSTRAINT [PK_BrowserHistory] PRIMARY KEY CLUSTERED ([AppBrowserID] ASC) WITH (FILLFACTOR = 50)
);

