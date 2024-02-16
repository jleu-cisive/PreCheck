CREATE TABLE [dbo].[AdverseAction] (
    [AdverseActionID]          INT            IDENTITY (1, 1) NOT NULL,
    [APNO]                     INT            NULL,
    [Hospital_CLNO]            INT            NULL,
    [AdverseContactID]         INT            CONSTRAINT [DF_AdverseAction_AdverseContactID] DEFAULT (0) NULL,
    [StatusID]                 INT            NULL,
    [PreAdverseLetterReturnID] INT            CONSTRAINT [DF_AdverseAction_PreAdverseLetterReturnID] DEFAULT (0) NULL,
    [AdverseLetterReturnID]    INT            CONSTRAINT [DF_AdverseAction_AdverseLetterReturnID] DEFAULT (0) NULL,
    [ClientEmail]              VARCHAR (1000) NULL,
    [Name]                     VARCHAR (150)  NULL,
    [Address1]                 VARCHAR (150)  NULL,
    [Address2]                 VARCHAR (150)  NULL,
    [City]                     VARCHAR (50)   NULL,
    [State]                    CHAR (2)       NULL,
    [Zip]                      CHAR (5)       NULL,
    [ApplicantEmail]           VARCHAR (1000) NULL,
    CONSTRAINT [PK_AdverseAction] PRIMARY KEY CLUSTERED ([AdverseActionID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_AdverseAction_APNO_CLNO]
    ON [dbo].[AdverseAction]([APNO] ASC, [Hospital_CLNO] ASC) WITH (FILLFACTOR = 70);

