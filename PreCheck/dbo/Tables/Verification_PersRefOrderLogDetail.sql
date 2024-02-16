CREATE TABLE [dbo].[Verification_PersRefOrderLogDetail] (
    [Verification_VendorOrderLogDetailID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Verification_VendorOrderLogID]       INT           NOT NULL,
    [Request]                             VARCHAR (MAX) NULL,
    [Response]                            VARCHAR (MAX) NULL,
    [EmailSentCount]                      INT           NULL,
    [EmailCurrentStatus]                  VARCHAR (50)  NULL,
    [EmailLastSentOn]                     DATETIME      NULL,
    [SMSSentCount]                        INT           NULL,
    [SMSCurrentStatus]                    VARCHAR (50)  NULL,
    [SMSLastSentOn]                       DATETIME      NULL,
    [LastUpdatedOn]                       DATETIME      NULL,
    [CreatedDate]                         DATETIME      CONSTRAINT [DF_Verification_VenderOrderLogDetail_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                           VARCHAR (50)  NULL,
    CONSTRAINT [PK_Verification_VenderOrderLogDetail] PRIMARY KEY CLUSTERED ([Verification_VendorOrderLogDetailID] ASC) ON [PRIMARY],
    CONSTRAINT [FK_Verification_VOLogDetail_Verification_VOLog] FOREIGN KEY ([Verification_VendorOrderLogID]) REFERENCES [dbo].[Verification_VendorOrderLog] ([Verification_VendorOrderLogID])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

