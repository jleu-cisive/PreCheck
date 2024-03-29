﻿CREATE TABLE [dbo].[PrecheckFramework_PublicRecordsStaging] (
    [PublicRecordsStagingId]   INT            IDENTITY (187309, 1) NOT NULL,
    [SectionId]                INT            NULL,
    [FolderId]                 VARCHAR (50)   NULL,
    [APNO]                     INT            NULL,
    [County]                   VARCHAR (40)   NOT NULL,
    [Clear]                    VARCHAR (1)    NULL,
    [Ordered]                  VARCHAR (14)   NULL,
    [Name]                     VARCHAR (100)  NULL,
    [DOB]                      DATETIME       NULL,
    [SSN]                      VARCHAR (11)   NULL,
    [CaseNo]                   VARCHAR (50)   NULL,
    [Date_Filed]               DATETIME       NULL,
    [Degree]                   VARCHAR (1)    NULL,
    [Offense]                  VARCHAR (1000) NULL,
    [Disposition]              VARCHAR (500)  NULL,
    [Sentence]                 VARCHAR (1000) NULL,
    [Fine]                     VARCHAR (100)  NULL,
    [Disp_Date]                DATETIME       NULL,
    [Pub_Notes]                NVARCHAR (MAX) NULL,
    [Priv_Notes]               NVARCHAR (MAX) NULL,
    [txtalias]                 CHAR (2)       NULL,
    [txtalias2]                CHAR (2)       NULL,
    [txtalias3]                CHAR (2)       NULL,
    [txtalias4]                CHAR (2)       NULL,
    [uniqueid]                 FLOAT (53)     NULL,
    [txtlast]                  CHAR (2)       NULL,
    [Crimenteredtime]          DATETIME       NULL,
    [Last_Updated]             DATETIME       NULL,
    [CNTY_NO]                  INT            NULL,
    [IRIS_REC]                 VARCHAR (3)    NULL,
    [CRIM_SpecialInstr]        NVARCHAR (MAX) NULL,
    [Report]                   TEXT           NULL,
    [batchnumber]              FLOAT (53)     NULL,
    [crim_time]                VARCHAR (50)   NULL,
    [vendorid]                 VARCHAR (50)   NULL,
    [deliverymethod]           VARCHAR (50)   NULL,
    [countydefault]            VARCHAR (50)   NULL,
    [status]                   VARCHAR (50)   NULL,
    [b_rule]                   VARCHAR (50)   NULL,
    [tobeworked]               BIT            NULL,
    [readytosend]              BIT            NULL,
    [NoteToVendor]             VARCHAR (50)   NULL,
    [test]                     VARCHAR (50)   NULL,
    [InUse]                    VARCHAR (20)   NULL,
    [parentCrimID]             INT            NULL,
    [IrisFlag]                 VARCHAR (10)   NULL,
    [IrisOrdered]              DATETIME       NULL,
    [Temporary]                BIT            NULL,
    [CreatedDate]              DATETIME       DEFAULT (getdate()) NULL,
    [IsCAMReview]              BIT            NULL,
    [IsHidden]                 BIT            NULL,
    [IsHistoryRecord]          BIT            NULL,
    [AliasParentCrimID]        INT            NULL,
    [InUseByIntegration]       VARCHAR (50)   NULL,
    [ClientAdjudicationStatus] INT            NULL,
    [AutoCheckAlias]           BIT            NULL,
    [AdmittedRecord]           BIT            DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Crim_Stg] PRIMARY KEY CLUSTERED ([PublicRecordsStagingId] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IDX_PublicRecordsStaging_FolderID_APNO_CreatedDate]
    ON [dbo].[PrecheckFramework_PublicRecordsStaging]([FolderId] ASC, [APNO] ASC, [CreatedDate] ASC) WITH (FILLFACTOR = 50);

