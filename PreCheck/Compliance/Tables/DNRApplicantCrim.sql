CREATE TABLE [Compliance].[DNRApplicantCrim] (
    [DNRApplicantCrimId] INT            IDENTITY (1, 1) NOT NULL,
    [SSN]                VARCHAR (11)   NOT NULL,
    [CNTY_NO]            INT            NOT NULL,
    [CaseNo]             VARCHAR (50)   NOT NULL,
    [Offence]            VARCHAR (1000) NOT NULL,
    [DispositionDate]    DATETIME       NOT NULL,
    [CreateDate]         DATETIME       CONSTRAINT [DF_DNRApplicantCrim_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]           VARCHAR (50)   NOT NULL,
    [ModifyDate]         DATETIME       CONSTRAINT [DF_DNRApplicantCrim_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]           VARCHAR (50)   NOT NULL,
    [IsActive]           BIT            CONSTRAINT [DF_DNRApplicantCrim_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DNRApplicantCrim] PRIMARY KEY CLUSTERED ([DNRApplicantCrimId] ASC) ON [PRIMARY]
) ON [PRIMARY];

