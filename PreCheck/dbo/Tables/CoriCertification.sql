CREATE TABLE [dbo].[CoriCertification] (
    [CoriCertificationId] INT           IDENTITY (1, 1) NOT NULL,
    [APNO]                INT           NOT NULL,
    [CertifyDate]         DATETIME      NULL,
    [UserSignature]       VARCHAR (150) NULL,
    [IPAddress]           VARCHAR (50)  NULL,
    [IsCertified]         BIT           CONSTRAINT [DF_CoriCertification_IsCertified] DEFAULT ((0)) NOT NULL,
    [IsActive]            BIT           CONSTRAINT [DF_CoriCertification_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]          DATETIME      CONSTRAINT [DF_CoriCertification_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]            INT           NOT NULL,
    [ModifyDate]          DATETIME      CONSTRAINT [DF_CoriCertification_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]            INT           NOT NULL,
    CONSTRAINT [PK_CoriCertification] PRIMARY KEY CLUSTERED ([CoriCertificationId] ASC),
    CONSTRAINT [APNO_UNIQUE] UNIQUE NONCLUSTERED ([APNO] ASC)
);

