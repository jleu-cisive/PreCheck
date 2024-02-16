CREATE TABLE [dbo].[EZVerifyUser] (
    [UID]         INT            IDENTITY (1, 1) NOT NULL,
    [EmailID]     NVARCHAR (100) NOT NULL,
    [Password]    NVARCHAR (20)  NULL,
    [FirstName]   NVARCHAR (20)  NOT NULL,
    [LastName]    NVARCHAR (20)  NOT NULL,
    [Company]     NVARCHAR (100) NOT NULL,
    [Phone]       NVARCHAR (25)  NULL,
    [Title]       NVARCHAR (50)  NOT NULL,
    [StreetInfo]  NVARCHAR (50)  NULL,
    [City]        NVARCHAR (20)  NULL,
    [State]       NVARCHAR (2)   NULL,
    [Country]     NVARCHAR (20)  NULL,
    [Zip]         NVARCHAR (12)  NULL,
    [CreatedDate] DATETIME       CONSTRAINT [DF_EZVerifyUser_CreatedDate] DEFAULT (getdate()) NULL,
    [LastUpdated] DATETIME       CONSTRAINT [DF_EZVerifyUser_LastUpdated] DEFAULT (getdate()) NULL,
    [Activated]   BIT            CONSTRAINT [DF_EZVerifyUser_Validated] DEFAULT ((0)) NOT NULL,
    [Fax]         VARCHAR (50)   NULL,
    CONSTRAINT [PK_EZVerifyUser_1] PRIMARY KEY CLUSTERED ([EmailID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [IX_EZVerifyUser] UNIQUE NONCLUSTERED ([UID] ASC) WITH (FILLFACTOR = 50)
);

