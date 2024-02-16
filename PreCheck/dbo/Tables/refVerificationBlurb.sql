CREATE TABLE [dbo].[refVerificationBlurb] (
    [VerificationBlurbID]      INT            IDENTITY (1, 1) NOT NULL,
    [VerificationBlurb]        VARCHAR (4000) NULL,
    [IsActive]                 TINYINT        NULL,
    [WebStatus]                INT            NULL,
    [SectStat]                 CHAR (1)       NULL,
    [VerificationBlurbCode]    INT            NULL,
    [VerificationPrivateNotes] VARCHAR (4000) NULL,
    [Investigator]             VARCHAR (30)   NULL,
    [VerificationBlurbType]    VARCHAR (20)   NULL,
    [SectSubStatusID]          INT            NULL,
    CONSTRAINT [PK_refVerificationBlurb] PRIMARY KEY CLUSTERED ([VerificationBlurbID] ASC) WITH (FILLFACTOR = 50)
);

