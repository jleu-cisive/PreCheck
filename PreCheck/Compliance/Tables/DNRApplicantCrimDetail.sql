CREATE TABLE [Compliance].[DNRApplicantCrimDetail] (
    [DNRApplicantCrimDetailId] INT          IDENTITY (1, 1) NOT NULL,
    [DNRApplicantCrimId]       INT          NOT NULL,
    [CrimId]                   INT          NOT NULL,
    [DNRAppSource]             VARCHAR (50) NULL,
    [CreateDate]               DATETIME     CONSTRAINT [DF_DNRApplicantCrimDetail_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                 VARCHAR (50) NOT NULL,
    [ModifyDate]               DATETIME     CONSTRAINT [DF_DNRApplicantCrimDetail_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]                 VARCHAR (50) NOT NULL,
    [IsActive]                 BIT          CONSTRAINT [DF_DNRApplicantCrimDetail_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DNRApplicantCrimDetail] PRIMARY KEY CLUSTERED ([DNRApplicantCrimDetailId] ASC),
    CONSTRAINT [FK_DNRApplicantCrimDetail_DNRApplicantCrim] FOREIGN KEY ([DNRApplicantCrimId]) REFERENCES [Compliance].[DNRApplicantCrim] ([DNRApplicantCrimId])
);

