CREATE TABLE [dbo].[Verification_Staging_Empl] (
    [EmplId]                      INT           NOT NULL,
    [FromDate]                    VARCHAR (50)  NULL,
    [ToDate]                      VARCHAR (50)  NULL,
    [Position]                    VARCHAR (50)  NULL,
    [Salary]                      VARCHAR (50)  NULL,
    [RFL]                         VARCHAR (100) NULL,
    [Ver_By]                      VARCHAR (50)  NULL,
    [Title]                       VARCHAR (50)  NULL,
    [Web_Status]                  INT           NULL,
    [SectStat]                    CHAR (2)      NULL,
    [Private_Notes]               VARCHAR (MAX) NULL,
    [Public_Notes]                VARCHAR (MAX) NULL,
    [Alias1_First]                VARCHAR (50)  NULL,
    [Alias1_Middle]               VARCHAR (50)  NULL,
    [Alias1_Last]                 VARCHAR (50)  NULL,
    [Alias2_First]                VARCHAR (50)  NULL,
    [Alias2_Middle]               VARCHAR (50)  NULL,
    [Alias2_Last]                 VARCHAR (50)  NULL,
    [Alias3_First]                VARCHAR (50)  NULL,
    [Alias3_Middle]               VARCHAR (50)  NULL,
    [Alias3_Last]                 VARCHAR (50)  NULL,
    [APNO]                        INT           NULL,
    [IsOnReport]                  BIT           NULL,
    [CreatedDate]                 DATETIME      NULL,
    [Operation]                   VARCHAR (50)  NULL,
    [HasFeeHistory]               BIT           DEFAULT ((0)) NULL,
    [SourceType]                  VARCHAR (100) NULL,
    [Verification_Staging_EmplId] INT           IDENTITY (1, 1) NOT NULL,
    [SectSubStatusID]             INT           NULL,
    [investigator]                VARCHAR (8)   NULL,
    CONSTRAINT [PK_Verification_Staging_Empl] PRIMARY KEY NONCLUSTERED ([Verification_Staging_EmplId] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE CLUSTERED INDEX [IDX_Verification_Staging_Empl_APNO]
    ON [dbo].[Verification_Staging_Empl]([APNO] ASC);

