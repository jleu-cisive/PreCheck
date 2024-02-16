CREATE TABLE [STG].[ApplicantCriminalHistory_CT] (
    [CommitDateTime]             DATETIME        NULL,
    [Operation]                  VARCHAR (3)     NULL,
    [__$start_lsn]               BINARY (10)     NOT NULL,
    [__$end_lsn]                 BINARY (10)     NULL,
    [__$seqval]                  BINARY (10)     NOT NULL,
    [__$operation]               INT             NOT NULL,
    [__$update_mask]             VARBINARY (128) NULL,
    [ApplicantCriminalHistoryId] INT             NULL,
    [ApplicantId]                INT             NULL,
    [County]                     VARCHAR (50)    NULL,
    [City]                       VARCHAR (50)    NULL,
    [State]                      VARCHAR (20)    NULL,
    [Country]                    VARCHAR (50)    NULL,
    [OffenseDate]                DATETIME        NULL,
    [OffenseDescription]         VARCHAR (200)   NULL,
    [CreateDate]                 DATETIME        NULL,
    [CreateBy]                   INT             NULL,
    [ModifyDate]                 DATETIME        NULL,
    [ModifyBy]                   INT             NULL
);

