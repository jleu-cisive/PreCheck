﻿CREATE TABLE [dbo].[Crim_Review] (
    [Crim_ReviewID]         INT            IDENTITY (1, 1) NOT NULL,
    [CrimID]                INT            NOT NULL,
    [DOB]                   DATETIME       NULL,
    [SSN]                   VARCHAR (11)   NULL,
    [CaseNo]                VARCHAR (50)   NULL,
    [Date_Filed]            DATETIME       NULL,
    [Degree]                VARCHAR (1)    NULL,
    [Offense]               VARCHAR (1000) NULL,
    [Disposition]           VARCHAR (500)  NULL,
    [Sentence]              VARCHAR (1000) NULL,
    [Fine]                  VARCHAR (50)   NULL,
    [Disp_Date]             DATETIME       NULL,
    [NotesCaseInformation]  VARCHAR (MAX)  NULL,
    [WarrantStatus]         VARCHAR (100)  NULL,
    [NameonRecord]          VARCHAR (300)  NULL,
    [SSN_OnRecord]          VARCHAR (11)   NULL,
    [DOB_OnRecord]          VARCHAR (12)   NULL,
    [CrimStatus]            VARCHAR (10)   NULL,
    [ResolvedStatus]        VARCHAR (10)   NULL,
    [ResolvedBy]            VARCHAR (10)   NULL,
    [ResolvedDate]          DATETIME       NULL,
    [AdditionalInformation] VARCHAR (1000) NULL,
    [AIMS_ReviewDate]       DATETIME       NULL,
    [RefDispositionID]      INT            NULL,
    CONSTRAINT [PK_Crim_Review] PRIMARY KEY CLUSTERED ([Crim_ReviewID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IDX_Crim_Review]
    ON [dbo].[Crim_Review]([CrimID] ASC) WITH (FILLFACTOR = 70);

