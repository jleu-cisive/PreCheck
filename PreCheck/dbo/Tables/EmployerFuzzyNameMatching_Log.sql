CREATE TABLE [dbo].[EmployerFuzzyNameMatching_Log] (
    [ID]                             INT            IDENTITY (1, 1) NOT NULL,
    [EmplID]                         INT            NOT NULL,
    [APNO]                           NVARCHAR (50)  NOT NULL,
    [EmployerName_ByCandidate]       NVARCHAR (150) NULL,
    [EmployerName_Normalized]        NVARCHAR (150) NULL,
    [EmployerName_ByTALX]            NVARCHAR (150) NULL,
    [Scorecard]                      INT            NULL,
    [CreatedDate]                    SMALLDATETIME  CONSTRAINT [DF_EmployerFuzzyNameMatching_Log_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [EmployerName_ByTALX_Normalized] NVARCHAR (150) NULL,
    [MatchPercent]                   INT            NULL,
    [IsUsed]                         BIT            NULL,
    CONSTRAINT [PK_EmployerFuzzyNameMatching_Log] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY];

