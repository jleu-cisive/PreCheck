CREATE TABLE [STG].[ApplicantAlias_CT] (
    [CommitDateTime]   DATETIME     NULL,
    [Operation]        VARCHAR (3)  NULL,
    [__$start_lsn]     BINARY (10)  NULL,
    [__$end_lsn]       BINARY (10)  NULL,
    [__$seqval]        BINARY (10)  NULL,
    [__$operation]     INT          NULL,
    [__$update_mask]   BINARY (128) NULL,
    [ApplicantId]      INT          NULL,
    [CreateDate]       DATETIME     NULL,
    [CreateBy]         INT          NULL,
    [ModifyDate]       DATETIME     NULL,
    [ModifyBy]         INT          NULL,
    [ApplicantAliasId] INT          NULL,
    [FirstName]        VARCHAR (50) NULL,
    [MiddleName]       VARCHAR (50) NULL,
    [LastName]         VARCHAR (50) NULL,
    [FromYear]         INT          NULL,
    [ToYear]           INT          NULL,
    [ApplicantNumber]  INT          NULL
);

