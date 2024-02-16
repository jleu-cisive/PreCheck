﻿CREATE TABLE [dbo].[Staging_CreateInvoiceMainPull] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [APNO]           INT           NOT NULL,
    [Amount]         SMALLMONEY    NULL,
    [Description]    VARCHAR (100) NULL,
    [Type]           SMALLINT      NOT NULL,
    [InvDetID]       INT           NOT NULL,
    [ApStatus]       CHAR (1)      NOT NULL,
    [Last]           VARCHAR (50)  NULL,
    [First]          VARCHAR (50)  NULL,
    [Middle]         VARCHAR (50)  NULL,
    [CompDate]       DATETIME      NULL,
    [CLNO]           SMALLINT      NOT NULL,
    [Update_Billing] BIT           NOT NULL,
    [DeptCode]       VARCHAR (20)  NULL,
    [Name]           VARCHAR (100) NULL,
    [Addr1]          VARCHAR (100) NULL,
    [Addr2]          VARCHAR (100) NULL,
    [City]           VARCHAR (50)  NULL,
    [State]          VARCHAR (20)  NULL,
    [Zip]            VARCHAR (20)  NULL,
    [TaxRate]        SMALLMONEY    NULL,
    [IsTaxExempt]    BIT           NOT NULL,
    [BillingCycle]   NVARCHAR (50) NULL
);
