﻿CREATE TABLE [dbo].[DecDSUSPI] (
    [InvoiceID]      FLOAT (53)     NULL,
    [bill-code]      NVARCHAR (255) NULL,
    [cust no]        NVARCHAR (255) NULL,
    [Cust Name]      NVARCHAR (255) NULL,
    [Requestor]      NVARCHAR (255) NULL,
    [Oracle ID]      FLOAT (53)     NULL,
    [loc-no]         NVARCHAR (255) NULL,
    [Loc Name]       NVARCHAR (255) NULL,
    [prod-code]      NVARCHAR (255) NULL,
    [date-svc]       DATETIME       NULL,
    [amt-bill]       FLOAT (53)     NULL,
    [empl-no]        NVARCHAR (255) NULL,
    [name]           NVARCHAR (255) NULL,
    [spec-no]        NVARCHAR (255) NULL,
    [coc-no]         NVARCHAR (255) NULL,
    [test-code]      NVARCHAR (255) NULL,
    [BgState]        NVARCHAR (255) NULL,
    [Tier]           NVARCHAR (255) NULL,
    [Spec Type]      NVARCHAR (255) NULL,
    [transaction id] NVARCHAR (255) NULL,
    [Comments]       NVARCHAR (255) NULL,
    [Precheck Fees]  MONEY          NULL,
    [Total]          MONEY          NULL,
    [Count]          FLOAT (53)     NULL
);
