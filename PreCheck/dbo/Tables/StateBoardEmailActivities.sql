CREATE TABLE [dbo].[StateBoardEmailActivities] (
    [EmailBatchID]     UNIQUEIDENTIFIER NOT NULL,
    [EmailReferenceID] VARCHAR (50)     NOT NULL,
    [ClientID]         INT              NOT NULL,
    [FacilityID]       INT              NULL,
    [DepartmentID]     INT              NULL,
    [IsSentToClient]   BIT              NOT NULL,
    [ClientEmail]      VARCHAR (4000)   NOT NULL,
    [SendStatus]       VARCHAR (100)    NOT NULL,
    [EmailFrom]        VARCHAR (1000)   NOT NULL,
    [EmailTo]          VARCHAR (4000)   NOT NULL,
    [EmailType]        VARCHAR (100)    NOT NULL,
    [EmailDateTime]    DATETIME         NOT NULL,
    [EmailFileName]    VARCHAR (300)    NULL,
    [EmailComment]     VARCHAR (4000)   NULL,
    [FailedReason]     VARCHAR (8000)   NULL,
    [EmailContent]     VARCHAR (MAX)    NULL,
    [EmailSubject]     VARCHAR (500)    NULL,
    CONSTRAINT [PK_StateBoardEmailActivities] PRIMARY KEY CLUSTERED ([EmailBatchID] ASC),
    CONSTRAINT [UQ_StateBoardEmailActivities_EmailReferenceID] UNIQUE NONCLUSTERED ([EmailReferenceID] ASC) WITH (FILLFACTOR = 50) ON [PRIMARY]
) TEXTIMAGE_ON [PRIMARY];

