﻿CREATE TABLE [dbo].[CandidatesWithDrugTests] (
    [OCHS_CandidateInfoID]                INT           NOT NULL,
    [CLNO]                                INT           NOT NULL,
    [APNO]                                INT           NULL,
    [LastName]                            VARCHAR (50)  NOT NULL,
    [FirstName]                           VARCHAR (50)  NOT NULL,
    [Middle]                              VARCHAR (20)  NULL,
    [SSN]                                 VARCHAR (11)  NULL,
    [DOB]                                 DATE          NULL,
    [Address1]                            VARCHAR (100) NULL,
    [Address2]                            VARCHAR (20)  NULL,
    [City]                                VARCHAR (50)  NULL,
    [State]                               CHAR (2)      NOT NULL,
    [Zip]                                 VARCHAR (10)  NOT NULL,
    [Email]                               VARCHAR (100) NOT NULL,
    [Phone]                               VARCHAR (12)  NOT NULL,
    [TestReason]                          INT           NOT NULL,
    [CostCenter]                          VARCHAR (50)  NULL,
    [ClientIdent]                         VARCHAR (100) NULL,
    [CreatedDate]                         DATETIME      NOT NULL,
    [LastUpdateDate]                      DATETIME      NOT NULL,
    [IsActive]                            BIT           NULL,
    [ClientConfiguration_DrugScreeningID] INT           NULL,
    [ZipcrimClientPackageID]              VARCHAR (6)   NULL,
    [PackageID]                           INT           NULL,
    [packagedesc]                         VARCHAR (100) NULL,
    [ClientName]                          VARCHAR (100) NULL,
    [ZipCrimClientID]                     VARCHAR (6)   NULL,
    [orderstatus]                         VARCHAR (25)  NULL,
    [datereceived]                        DATETIME      NULL,
    [testresult]                          VARCHAR (25)  NULL,
    [coc]                                 VARCHAR (25)  NULL,
    [OrderIDOrAPNO]                       VARCHAR (25)  NULL,
    [FacilityClientNO]                    SMALLINT      NULL
);

