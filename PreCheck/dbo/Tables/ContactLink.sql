CREATE TABLE [dbo].[ContactLink] (
    [ContactID]        INT     NOT NULL,
    [LinkEntityTypeID] TINYINT NOT NULL,
    [LinkEntityKey]    INT     NOT NULL,
    CONSTRAINT [PK_ContactLink] PRIMARY KEY CLUSTERED ([ContactID] ASC, [LinkEntityTypeID] ASC, [LinkEntityKey] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ContactLink_Contact] FOREIGN KEY ([ContactID]) REFERENCES [dbo].[Contact] ([ContactID])
);

