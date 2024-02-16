CREATE TABLE [dbo].[Integration_OrderMgmt_DuplicateRequests] (
    [DuplicateRequestID]      INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                    INT           NULL,
    [Partner_Reference]       VARCHAR (50)  NULL,
    [Partner_Tracking_Number] VARCHAR (50)  NULL,
    [ClientCandidateId]       VARCHAR (100) NULL,
    [Request]                 VARCHAR (MAX) NULL,
    [RequestDate]             DATETIME      CONSTRAINT [Integration_OrderMgmt_DuplicateRequests_RequestDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Integration_OrderMgmt_DuplicateRequests] PRIMARY KEY CLUSTERED ([DuplicateRequestID] ASC) WITH (FILLFACTOR = 70)
) TEXTIMAGE_ON [PRIMARY];

