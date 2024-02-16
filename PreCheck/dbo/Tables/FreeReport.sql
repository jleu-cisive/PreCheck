CREATE TABLE [dbo].[FreeReport] (
    [FreeReportID]             INT            IDENTITY (1, 1) NOT NULL,
    [APNO]                     INT            NULL,
    [CLNO]                     INT            NULL,
    [StatusID]                 INT            NULL,
    [FreeReportLetterReturnID] INT            CONSTRAINT [DF_FreeReport_PreAdverseLetterReturnID] DEFAULT ((0)) NULL,
    [2ndLetterReturnID]        INT            NULL,
    [Name]                     VARCHAR (150)  NULL,
    [Address1]                 VARCHAR (150)  NULL,
    [Address2]                 VARCHAR (150)  NULL,
    [City]                     VARCHAR (50)   NULL,
    [State]                    CHAR (2)       NULL,
    [Zip]                      CHAR (5)       NULL,
    [ApplicantEmail]           VARCHAR (1000) NULL,
    CONSTRAINT [PK_FreeReport] PRIMARY KEY CLUSTERED ([FreeReportID] ASC) WITH (FILLFACTOR = 50)
);

