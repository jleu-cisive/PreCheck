CREATE TABLE [dbo].[Iris_Researcher_Charges_bkup_080817] (
    [id]                       INT          IDENTITY (1, 1) NOT NULL,
    [Researcher_id]            INT          NULL,
    [Researcher_county]        VARCHAR (50) NULL,
    [Researcher_state]         VARCHAR (50) NULL,
    [Researcher_Fel]           VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_Fel_bkup_080817] DEFAULT ((0)) NULL,
    [Researcher_Mis]           VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_Mis_bkup_080817] DEFAULT ((0)) NULL,
    [Researcher_fed]           VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_fed_bkup_080817] DEFAULT ((0)) NULL,
    [Researcher_alias]         VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_alias_bkup_080817] DEFAULT ((0)) NULL,
    [Researcher_combo]         VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_combo_bkup_080817] DEFAULT ((0)) NULL,
    [Researcher_other]         VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_other_bkup_080817] DEFAULT ((0)) NULL,
    [Researcher_Default]       VARCHAR (3)  CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_Default_bkup_080817] DEFAULT ((0)) NULL,
    [Researcher_Aliases_count] VARCHAR (4)  NULL,
    [cnty_no]                  INT          NULL,
    [Researcher_CourtFees]     VARCHAR (50) CONSTRAINT [DF_Iris_Researcher_Charges_Researcher_CourtFees_bkup_080817] DEFAULT ((0)) NULL,
    [TxDPS]                    BIT          CONSTRAINT [DF_Iris_Researcher_Charges_TxDPS_bkup_080817] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Iris_Researcher_Charges_bkup_080817] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

