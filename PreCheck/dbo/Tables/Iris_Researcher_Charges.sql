CREATE TABLE [dbo].[Iris_Researcher_Charges] (
    [id]                       INT          IDENTITY (1, 1) NOT NULL,
    [Researcher_id]            INT          NULL,
    [Researcher_county]        VARCHAR (50) NULL,
    [Researcher_state]         VARCHAR (50) NULL,
    [Researcher_Fel]           VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_Fel] DEFAULT (0) NULL,
    [Researcher_Mis]           VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_Mis] DEFAULT (0) NULL,
    [Researcher_fed]           VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_fed] DEFAULT (0) NULL,
    [Researcher_alias]         VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_alias] DEFAULT (0) NULL,
    [Researcher_combo]         VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_combo] DEFAULT (0) NULL,
    [Researcher_other]         VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_other] DEFAULT (0) NULL,
    [Researcher_Default]       VARCHAR (3)  CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_Default] DEFAULT (0) NULL,
    [Researcher_Aliases_count] VARCHAR (4)  NULL,
    [cnty_no]                  INT          NULL,
    [Researcher_CourtFees]     VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_CourtFees] DEFAULT (0) NULL,
    [TxDPS]                    BIT          CONSTRAINT [DF_Iris_Researcher_Charges_TxDPS] DEFAULT (0) NULL,
    CONSTRAINT [PK_Iris_Researcher_Charges_1] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_Iris_Researcher_Charges_01]
    ON [dbo].[Iris_Researcher_Charges]([Researcher_id] ASC, [cnty_no] ASC) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IX_Iris_Researcher_Charges_02]
    ON [dbo].[Iris_Researcher_Charges]([Researcher_Default] ASC)
    INCLUDE([Researcher_id], [cnty_no]);

