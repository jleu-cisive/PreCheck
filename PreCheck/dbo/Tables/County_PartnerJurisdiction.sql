CREATE TABLE [dbo].[County_PartnerJurisdiction] (
    [ID]                       INT           IDENTITY (1, 1) NOT NULL,
    [CNTY_NO]                  INT           NOT NULL,
    [LeadType]                 VARCHAR (50)  NOT NULL,
    [State]                    VARCHAR (25)  NOT NULL,
    [County]                   VARCHAR (100) NOT NULL,
    [PreCheckCounty]           VARCHAR (40)  NULL,
    [JurisdictionName]         VARCHAR (100) NOT NULL,
    [PreCheckJurisdictionName] VARCHAR (100) NOT NULL,
    [PreCheckComment]          VARCHAR (500) NULL,
    [PartnerId]                INT           NULL,
    [IsActive]                 BIT           CONSTRAINT [DF_County_PartnerJurisdiction_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateBy]                 INT           NOT NULL,
    [CreateDate]               DATETIME      NOT NULL,
    [ModifyBy]                 INT           NOT NULL,
    [ModifyDate]               DATETIME      NOT NULL,
    CONSTRAINT [PK_County_PartnerJurisdiction_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [IX_County_PartnerJurisdiction_PartnerID]
    ON [dbo].[County_PartnerJurisdiction]([PartnerId] ASC)
    INCLUDE([CNTY_NO], [State], [County]);

