CREATE TABLE [dbo].[ApplInvestigatorCreditDetail] (
    [ApplInvestigatorCreditDetailID] INT          IDENTITY (1, 1) NOT NULL,
    [ApplInvestigatorCreditID]       INT          NOT NULL,
    [Section]                        VARCHAR (10) NULL,
    [SectionID]                      INT          NOT NULL,
    [CreatedDate]                    DATETIME     DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ApplInvestigatorCreditDetail] PRIMARY KEY CLUSTERED ([ApplInvestigatorCreditDetailID] ASC) WITH (FILLFACTOR = 50)
);

