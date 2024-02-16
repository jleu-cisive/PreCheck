CREATE TABLE [dbo].[ApplInvestigatorCredit] (
    [ApplInvestigatorCreditID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                     INT          NOT NULL,
    [Investigator]             VARCHAR (20) NOT NULL,
    [refCredit]                CHAR (1)     NOT NULL,
    [CreatedDate]              DATETIME     DEFAULT (getdate()) NOT NULL,
    [LastModifiedDate]         DATETIME     DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ApplInvestigatorCredits] PRIMARY KEY CLUSTERED ([ApplInvestigatorCreditID] ASC) WITH (FILLFACTOR = 50)
);

