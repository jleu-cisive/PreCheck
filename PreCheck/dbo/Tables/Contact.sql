CREATE TABLE [dbo].[Contact] (
    [ContactID]        INT          IDENTITY (1, 1) NOT NULL,
    [ContactName]      VARCHAR (30) NOT NULL,
    [CompanyName]      VARCHAR (30) NULL,
    [Phone1]           VARCHAR (20) NULL,
    [Fax1]             VARCHAR (20) NULL,
    [Phone2]           VARCHAR (20) NULL,
    [Fax2]             VARCHAR (20) NULL,
    [Email]            VARCHAR (50) NULL,
    [Addr1]            VARCHAR (30) NULL,
    [Addr2]            VARCHAR (30) NULL,
    [City]             VARCHAR (30) NULL,
    [State]            VARCHAR (2)  NULL,
    [Zip]              VARCHAR (10) NULL,
    [LastModifiedUser] VARCHAR (30) NOT NULL,
    [LastModifiedDate] DATETIME     CONSTRAINT [DF_Contact_LastModifiedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Contact] PRIMARY KEY CLUSTERED ([ContactID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_Contact_ContactName]
    ON [dbo].[Contact]([ContactName] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

