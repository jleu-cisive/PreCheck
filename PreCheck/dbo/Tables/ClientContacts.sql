CREATE TABLE [dbo].[ClientContacts] (
    [ContactID]       INT            IDENTITY (1, 1) NOT NULL,
    [CLNO]            SMALLINT       NULL,
    [PrimaryContact]  BIT            CONSTRAINT [DF_ClientContacts_PrimaryContact] DEFAULT (0) NOT NULL,
    [ContactType]     NVARCHAR (50)  NULL,
    [ContactTypeID]   INT            NULL,
    [ReportFlag]      BIT            CONSTRAINT [DF_ClientContacts_ReportFlag] DEFAULT (0) NOT NULL,
    [Title]           NVARCHAR (50)  NULL,
    [FirstName]       NVARCHAR (50)  NULL,
    [MiddleName]      NVARCHAR (50)  NULL,
    [LastName]        NVARCHAR (50)  NULL,
    [Phone]           NVARCHAR (30)  NULL,
    [Ext]             NVARCHAR (30)  NULL,
    [Email]           NVARCHAR (150) NULL,
    [tmpPhone]        VARCHAR (50)   NULL,
    [username]        VARCHAR (14)   NULL,
    [UserPassword]    VARCHAR (14)   NULL,
    [WOLockout]       INT            CONSTRAINT [DF_ClientContacts_WOLockout] DEFAULT (0) NOT NULL,
    [GetsReportEmail] BIT            CONSTRAINT [DF_ClientContacts_GetsReportEmail] DEFAULT (0) NULL,
    [GetsReport]      BIT            CONSTRAINT [DF_ClientContacts_GetsReport] DEFAULT (0) NOT NULL,
    [IsActive]        BIT            CONSTRAINT [DF_ClientContacts_IsActive] DEFAULT (1) NOT NULL,
    [ClientRoleID]    INT            NULL,
    CONSTRAINT [PK_ClientContacts] PRIMARY KEY CLUSTERED ([ContactID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_CLNO_ISACTIVE]
    ON [dbo].[ClientContacts]([CLNO] ASC, [IsActive] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [CLNO_username]
    ON [dbo].[ClientContacts]([CLNO] ASC, [username] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IX_ClientContacts_GetsReport_IsActive]
    ON [dbo].[ClientContacts]([GetsReport] ASC, [IsActive] ASC)
    INCLUDE([CLNO]);

