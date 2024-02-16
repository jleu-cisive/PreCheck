CREATE TABLE [dbo].[PrecheckVendors] (
    [PrecheckVendorsID] INT            IDENTITY (1, 1) NOT NULL,
    [CompanyName]       VARCHAR (255)  NULL,
    [ContactName]       VARCHAR (100)  NULL,
    [ContactEmail]      VARCHAR (255)  NULL,
    [ContactPhone]      VARCHAR (50)   NULL,
    [ITContactName]     VARCHAR (100)  NULL,
    [ITContactEmail]    VARCHAR (255)  NULL,
    [ITContactPhone]    VARCHAR (50)   NULL,
    [LoginUserId]       VARCHAR (50)   NULL,
    [LoginPassword]     VARCHAR (50)   NULL,
    [WebSite]           VARCHAR (500)  NULL,
    [Note]              VARCHAR (1500) NULL,
    CONSTRAINT [PK_PrecheckVendors] PRIMARY KEY CLUSTERED ([PrecheckVendorsID] ASC) WITH (FILLFACTOR = 50)
);

