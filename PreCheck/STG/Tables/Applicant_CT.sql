﻿CREATE TABLE [STG].[Applicant_CT] (
    [CommitDateTime]           DATETIME      NULL,
    [Operation]                VARCHAR (3)   NULL,
    [__$start_lsn]             BINARY (10)   NULL,
    [__$end_lsn]               BINARY (10)   NULL,
    [__$seqval]                BINARY (10)   NULL,
    [__$operation]             INT           NULL,
    [__$update_mask]           BINARY (128)  NULL,
    [Phone]                    VARCHAR (20)  NULL,
    [OrderId]                  INT           NULL,
    [OrderStatus]              VARCHAR (1)   NULL,
    [Email]                    VARCHAR (250) NULL,
    [ApplicantId]              INT           NULL,
    [ApplicantNumber]          VARCHAR (20)  NULL,
    [LastName]                 VARCHAR (50)  NULL,
    [FirstName]                VARCHAR (50)  NULL,
    [MiddleName]               VARCHAR (50)  NULL,
    [SocialNumber]             VARCHAR (11)  NULL,
    [DateOfBirth]              DATE          NULL,
    [DAGenderId]               INT           NULL,
    [NameOnDriverLicense]      VARCHAR (150) NULL,
    [DriverLicenseState]       VARCHAR (20)  NULL,
    [DriverLicenseNumber]      VARCHAR (20)  NULL,
    [I94]                      VARCHAR (50)  NULL,
    [CellPhone]                VARCHAR (20)  NULL,
    [OtherPhone]               VARCHAR (20)  NULL,
    [ForeignIdNumber]          VARCHAR (100) NULL,
    [DocumentType]             VARCHAR (100) NULL,
    [HasSelfDisclosedCriminal] BIT           NULL,
    [ProfileUserId]            INT           NULL,
    [CreateDate]               DATETIME      NULL,
    [CreateBy]                 INT           NULL,
    [ModifyDate]               DATETIME      NULL,
    [ModifyBy]                 INT           NULL,
    [IntegrationRequestId]     INT           NULL,
    [FacilityId]               INT           NULL
);
