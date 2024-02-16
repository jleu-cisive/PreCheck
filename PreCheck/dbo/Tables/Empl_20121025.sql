﻿CREATE TABLE [dbo].[Empl_20121025] (
    [EmplID]                   INT           IDENTITY (153901, 1) NOT NULL,
    [Apno]                     INT           NOT NULL,
    [Employer]                 VARCHAR (30)  NOT NULL,
    [Location]                 VARCHAR (250) NULL,
    [SectStat]                 CHAR (1)      NOT NULL,
    [Worksheet]                BIT           NOT NULL,
    [Phone]                    VARCHAR (20)  NULL,
    [Supervisor]               VARCHAR (25)  NULL,
    [SupPhone]                 VARCHAR (20)  NULL,
    [Dept]                     VARCHAR (30)  NULL,
    [RFL]                      VARCHAR (30)  NULL,
    [DNC]                      BIT           NOT NULL,
    [SpecialQ]                 BIT           NOT NULL,
    [Ver_Salary]               BIT           NOT NULL,
    [From_A]                   VARCHAR (12)  NULL,
    [To_A]                     VARCHAR (12)  NULL,
    [Position_A]               VARCHAR (25)  NULL,
    [Salary_A]                 VARCHAR (15)  NULL,
    [From_V]                   VARCHAR (30)  NULL,
    [To_V]                     VARCHAR (30)  NULL,
    [Position_V]               VARCHAR (50)  NULL,
    [Salary_V]                 VARCHAR (50)  NULL,
    [Emp_Type]                 CHAR (1)      NOT NULL,
    [Rel_Cond]                 CHAR (1)      NOT NULL,
    [Rehire]                   VARCHAR (1)   NULL,
    [Ver_By]                   VARCHAR (50)  NULL,
    [Title]                    VARCHAR (25)  NULL,
    [Priv_Notes]               TEXT          NULL,
    [Pub_Notes]                TEXT          NULL,
    [web_status]               INT           NULL,
    [web_updated]              DATETIME      NULL,
    [Includealias]             CHAR (1)      NULL,
    [Includealias2]            CHAR (1)      NULL,
    [Includealias3]            CHAR (1)      NULL,
    [Includealias4]            CHAR (1)      NULL,
    [PendingUpdated]           DATETIME      NULL,
    [Time_In]                  DATETIME      NULL,
    [Last_Updated]             DATETIME      NULL,
    [city]                     CHAR (16)     NULL,
    [state]                    CHAR (2)      NULL,
    [zipcode]                  CHAR (5)      NULL,
    [Investigator]             VARCHAR (8)   NULL,
    [EmployerID]               INT           NULL,
    [InvestigatorAssigned]     DATETIME      NULL,
    [PendingChanged]           DATETIME      NULL,
    [TempInvestigator]         VARCHAR (10)  NULL,
    [InUse]                    VARCHAR (8)   NULL,
    [CreatedDate]              DATETIME      NULL,
    [EnteredBy]                VARCHAR (50)  NULL,
    [EnteredDate]              DATETIME      NULL,
    [IsCamReview]              BIT           NULL,
    [Last_Worked]              DATETIME      NULL,
    [ClientEmployerID]         INT           NULL,
    [AutoFaxStatus]            INT           NULL,
    [IsOnReport]               BIT           NOT NULL,
    [IsHidden]                 BIT           NOT NULL,
    [IsHistoryRecord]          BIT           NOT NULL,
    [EmploymentStatus]         VARCHAR (50)  NULL,
    [IsOKtoContact]            BIT           NOT NULL,
    [OKtoContactInitial]       VARCHAR (15)  NULL,
    [EmplVerifyID]             INT           NULL,
    [GetNextDate]              DATETIME      NULL,
    [SubStatusID]              INT           NULL,
    [ClientAdjudicationStatus] INT           NULL,
    [ClientRefID]              VARCHAR (25)  NULL,
    [IsIntl]                   BIT           NULL,
    [DateOrdered]              DATETIME      NULL,
    [OrderId]                  VARCHAR (20)  NULL
);
