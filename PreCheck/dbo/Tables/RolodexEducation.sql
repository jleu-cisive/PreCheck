﻿CREATE TABLE [dbo].[RolodexEducation] (
    [RolodexEducationID] INT            IDENTITY (1, 1) NOT NULL,
    [School]             VARCHAR (120)  NOT NULL,
    [Initials]           VARCHAR (30)   NULL,
    [Fax]                VARCHAR (30)   NULL,
    [Phone]              VARCHAR (30)   NULL,
    [RegistrarPhone]     VARCHAR (30)   NULL,
    [Email]              VARCHAR (255)  NULL,
    [WebPage]            VARCHAR (500)  NULL,
    [Address]            VARCHAR (100)  NULL,
    [City]               VARCHAR (30)   NULL,
    [State]              VARCHAR (2)    NULL,
    [Zip]                VARCHAR (20)   NULL,
    [Country]            VARCHAR (30)   NULL,
    [Note]               VARCHAR (8000) NULL,
    [CLNO]               INT            NULL,
    [ContactMethod]      INT            NULL,
    [ReleaseRequired]    BIT            NOT NULL,
    [Deleted]            BIT            NOT NULL,
    [LastUpdate]         DATETIME       NULL,
    [CreatedDate]        DATETIME       NULL,
    [NCHID]              VARCHAR (30)   NULL,
    [ContactName]        VARCHAR (75)   NULL,
    [ContactTitle]       VARCHAR (75)   NULL,
    [FaxToAttnOf]        VARCHAR (75)   NULL,
    [AlternateFax]       VARCHAR (30)   NULL,
    CONSTRAINT [PK_RolodexEducation] PRIMARY KEY CLUSTERED ([RolodexEducationID] ASC) WITH (FILLFACTOR = 50)
);

