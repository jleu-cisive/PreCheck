CREATE TABLE [STG].[ApplicantReference_CT] (
    [CommitDateTime]       DATETIME      NULL,
    [Operation]            VARCHAR (3)   NULL,
    [__$start_lsn]         BINARY (10)   NULL,
    [__$end_lsn]           BINARY (10)   NULL,
    [__$seqval]            BINARY (10)   NULL,
    [__$operation]         INT           NULL,
    [__$update_mask]       BINARY (128)  NULL,
    [ApplicantId]          INT           NULL,
    [CreateDate]           DATETIME      NULL,
    [CreateBy]             INT           NULL,
    [ModifyDate]           DATETIME      NULL,
    [ModifyBy]             INT           NULL,
    [ApplicantReferenceId] INT           NULL,
    [ReferenceName]        VARCHAR (100) NULL,
    [Phone]                VARCHAR (20)  NULL,
    [CompanyName]          VARCHAR (100) NULL,
    [JobTitle]             VARCHAR (100) NULL,
    [Email]                VARCHAR (250) NULL,
    [ReferenceRelation]    VARCHAR (50)  NULL,
    [YearsKnown]           INT           NULL,
    [ApplicantNumber]      INT           NULL
);

