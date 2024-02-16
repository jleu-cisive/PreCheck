CREATE TABLE [dbo].[OracleCandidateInfo] (
    [OracleCandidateInfoID] INT            IDENTITY (1, 1) NOT NULL,
    [PartnerUsername]       VARCHAR (50)   NULL,
    [ClientRefKey]          VARCHAR (50)   NULL,
    [RequisitionNumber]     VARCHAR (50)   NULL,
    [CandidateNumber]       VARCHAR (50)   NULL,
    [PIIFlag]               CHAR (1)       NULL,
    [CandidateToken]        VARCHAR (1000) NULL,
    CONSTRAINT [PK_OracleCandidateInfo] PRIMARY KEY CLUSTERED ([OracleCandidateInfoID] ASC) ON [PRIMARY]
) ON [PRIMARY];

