CREATE TABLE [dbo].[SSAS_Appl_Rpts] (
    [Name]                VARCHAR (100) NULL,
    [ProcessLevel]        VARCHAR (20)  NULL,
    [ClientFacilitygroup] VARCHAR (50)  NULL,
    [Division]            VARCHAR (50)  NULL,
    [Date]                DATETIME      NULL,
    [Completed_Reopen]    INT           NOT NULL,
    [No_Of_days_Appl]     INT           NULL,
    [No_Of_Days_Complete] INT           NULL,
    [Appl_Cnt]            INT           NOT NULL,
    [Comp_Appl_Cnt]       INT           NOT NULL,
    [Cr_Appl_Cnt]         INT           NOT NULL
);

