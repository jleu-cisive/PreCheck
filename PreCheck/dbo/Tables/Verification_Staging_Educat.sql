﻿CREATE TABLE [dbo].[Verification_Staging_Educat] (
    [EducatId]                     INT           NOT NULL,
    [FromDate]                     VARCHAR (12)  NULL,
    [ToDate]                       VARCHAR (12)  NULL,
    [Degree]                       VARCHAR (50)  NULL,
    [Studies]                      VARCHAR (50)  NULL,
    [City]                         VARCHAR (50)  NULL,
    [Phone]                        VARCHAR (20)  NULL,
    [School]                       VARCHAR (50)  NULL,
    [State]                        VARCHAR (2)   NULL,
    [SectStat]                     VARCHAR (1)   NULL,
    [Web_Status]                   INT           NULL,
    [Private_Notes]                VARCHAR (MAX) NULL,
    [Public_Notes]                 VARCHAR (MAX) NULL,
    [Alias1_First]                 VARCHAR (50)  NULL,
    [Alias1_Middle]                VARCHAR (50)  NULL,
    [Alias1_Last]                  VARCHAR (50)  NULL,
    [Alias2_First]                 VARCHAR (50)  NULL,
    [Alias2_Middle]                VARCHAR (50)  NULL,
    [Alias2_Last]                  VARCHAR (50)  NULL,
    [Alias3_First]                 VARCHAR (50)  NULL,
    [Alias3_Middle]                VARCHAR (50)  NULL,
    [Alias3_Last]                  VARCHAR (50)  NULL,
    [APNO]                         INT           NULL,
    [IsOnReport]                   BIT           NULL,
    [CreatedDate]                  DATETIME      NULL,
    [Ver_By]                       VARCHAR (50)  NULL,
    [Title]                        VARCHAR (50)  NULL,
    [Operation]                    VARCHAR (50)  NULL,
    [HasFeeHistory]                BIT           DEFAULT ((0)) NULL,
    [VerificationStaggingEducatId] INT           IDENTITY (1, 1) NOT NULL,
    [OrderId]                      VARCHAR (20)  NULL,
    [Investigator]                 VARCHAR (30)  NULL,
    PRIMARY KEY NONCLUSTERED ([VerificationStaggingEducatId] ASC)
);

