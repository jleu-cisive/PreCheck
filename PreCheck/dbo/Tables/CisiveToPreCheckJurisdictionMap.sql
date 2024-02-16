CREATE TABLE [dbo].[CisiveToPreCheckJurisdictionMap] (
    [ID]                       INT           IDENTITY (1, 1) NOT NULL,
    [CNTY_NO]                  INT           NOT NULL,
    [LeadType]                 VARCHAR (50)  NOT NULL,
    [State]                    VARCHAR (25)  NOT NULL,
    [County]                   VARCHAR (100) NOT NULL,
    [JurisdictionName]         VARCHAR (100) NOT NULL,
    [PreCheckJurisdictionName] VARCHAR (100) NOT NULL,
    [PreCheckComment]          VARCHAR (500) NULL,
    [IsActive]                 BIT           NOT NULL,
    CONSTRAINT [PK_CisiveToPreCheckJurisdictionMap_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

