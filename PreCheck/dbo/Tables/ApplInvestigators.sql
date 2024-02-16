CREATE TABLE [dbo].[ApplInvestigators] (
    [ApplInvestigatorsID]        INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                       INT          NOT NULL,
    [Section]                    VARCHAR (10) NOT NULL,
    [Investigator]               VARCHAR (20) NOT NULL,
    [Effective_ActivationDate]   DATE         CONSTRAINT [DF_ApplInvestigators_Effective_ActivationDate] DEFAULT (getdate()) NOT NULL,
    [Effective_InActivationDate] DATE         NULL,
    [CreatedDate]                DATETIME     CONSTRAINT [DF_ApplInvestigators_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedDate]               DATETIME     CONSTRAINT [DF_ApplInvestigators_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ApplInvestigators] PRIMARY KEY CLUSTERED ([ApplInvestigatorsID] ASC) WITH (FILLFACTOR = 50)
);

