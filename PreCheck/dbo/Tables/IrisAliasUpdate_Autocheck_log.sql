﻿CREATE TABLE [dbo].[IrisAliasUpdate_Autocheck_log] (
    [AutoCheckIrisAliasID] INT          IDENTITY (1, 1) NOT NULL,
    [CrimID]               INT          NOT NULL,
    [ReadyToSend]          BIT          NULL,
    [ReadyToSend_Old]      NCHAR (10)   NULL,
    [txtLast]              BIT          NULL,
    [txtLast_Old]          NCHAR (10)   NULL,
    [txtAlias]             BIT          NULL,
    [txtAlias_Old]         NCHAR (10)   NULL,
    [txtAlias2]            BIT          NULL,
    [txtAlias2_Old]        NCHAR (10)   NULL,
    [txtAlias3]            BIT          NULL,
    [txtAlias3_Old]        NCHAR (10)   NULL,
    [txtAlias4]            BIT          NULL,
    [txtAlias4_Old]        NCHAR (10)   NULL,
    [apStatus]             CHAR (1)     NULL,
    [iris_Rec]             VARCHAR (3)  NULL,
    [Clear]                VARCHAR (1)  NULL,
    [Clear_Old]            VARCHAR (1)  NULL,
    [batchNumber]          FLOAT (53)   NULL,
    [batchNumber_Old]      FLOAT (53)   NULL,
    [deliverymethod]       VARCHAR (50) NULL,
    [crimenteredtime]      DATETIME     NULL,
    [insertTimeStamp]      DATETIME     NULL,
    [DoneVia]              VARCHAR (20) NULL
);

