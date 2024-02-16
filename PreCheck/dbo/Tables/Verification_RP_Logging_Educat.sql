﻿CREATE TABLE [dbo].[Verification_RP_Logging_Educat] (
    [LogID]         INT           IDENTITY (1, 1) NOT NULL,
    [EducatId]      INT           NULL,
    [FromDate]      VARCHAR (50)  NULL,
    [ToDate]        VARCHAR (50)  NULL,
    [Degree]        VARCHAR (50)  NULL,
    [Studies]       VARCHAR (50)  NULL,
    [City]          VARCHAR (100) NULL,
    [Phone]         VARCHAR (50)  NULL,
    [School]        VARCHAR (50)  NULL,
    [State]         VARCHAR (20)  NULL,
    [SectStat]      CHAR (2)      NULL,
    [Web_Status]    INT           NULL,
    [Private_Notes] VARCHAR (MAX) NULL,
    [Public_Notes]  VARCHAR (MAX) NULL,
    [Alias1_First]  VARCHAR (50)  NULL,
    [Alias1_Middle] VARCHAR (50)  NULL,
    [Alias1_Last]   VARCHAR (50)  NULL,
    [Alias2_First]  VARCHAR (50)  NULL,
    [Alias2_Middle] VARCHAR (50)  NULL,
    [Alias2_Last]   VARCHAR (50)  NULL,
    [Alias3_First]  VARCHAR (50)  NULL,
    [Alias3_Middle] VARCHAR (50)  NULL,
    [Alias3_Last]   VARCHAR (50)  NULL,
    [APNO]          INT           NULL,
    [IsOnReport]    BIT           NULL,
    [CreatedDate]   DATETIME      NULL,
    [Ver_By]        VARCHAR (50)  NULL,
    [Title]         VARCHAR (50)  NULL,
    CONSTRAINT [PK_Verification_RP_Logging_Educat] PRIMARY KEY CLUSTERED ([LogID] ASC)
);

