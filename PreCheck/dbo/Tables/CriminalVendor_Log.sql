CREATE TABLE [dbo].[CriminalVendor_Log] (
    [logID]             INT            IDENTITY (1, 1) NOT NULL,
    [APNO]              INT            NOT NULL,
    [County]            VARCHAR (40)   NOT NULL,
    [Clear]             VARCHAR (1)    NULL,
    [Ordered]           VARCHAR (14)   NULL,
    [Name]              NVARCHAR (100) NULL,
    [DOB]               DATETIME       NULL,
    [SSN]               VARCHAR (11)   NULL,
    [CaseNo]            VARCHAR (50)   NULL,
    [Date_Filed]        DATETIME       NULL,
    [Degree]            VARCHAR (1)    NULL,
    [Offense]           VARCHAR (1000) NULL,
    [Disposition]       VARCHAR (500)  NULL,
    [Sentence]          VARCHAR (1000) NULL,
    [Fine]              NVARCHAR (100) NULL,
    [Disp_Date]         DATETIME       NULL,
    [Pub_Notes]         TEXT           NULL,
    [Priv_Notes]        TEXT           NULL,
    [txtalias]          CHAR (2)       NULL,
    [txtalias2]         CHAR (2)       NULL,
    [txtalias3]         CHAR (2)       NULL,
    [txtalias4]         CHAR (2)       NULL,
    [txtlast]           CHAR (2)       NULL,
    [Last_Updated]      DATETIME       CONSTRAINT [DF__CriminalV__Last___79E9A1D3] DEFAULT (getdate()) NULL,
    [CNTY_NO]           INT            NULL,
    [IRIS_REC]          VARCHAR (3)    NULL,
    [CRIM_SpecialInstr] TEXT           NULL,
    [vendorid]          VARCHAR (50)   NULL,
    [deliverymethod]    VARCHAR (100)  NULL,
    [b_rule]            VARCHAR (50)   NULL,
    [EnteredDate]       DATETIME       CONSTRAINT [DF_CriminalVendor_Log_EnteredDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_CriminalVendor_Log] PRIMARY KEY CLUSTERED ([logID] ASC)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IDX_CriminalVendor_Log-APNO_CNTYNO]
    ON [dbo].[CriminalVendor_Log]([APNO] ASC, [CNTY_NO] ASC)
    INCLUDE([EnteredDate]) WITH (FILLFACTOR = 70);

