CREATE TABLE [dbo].[Integration_OrderMgmt_Request] (
    [RequestID]                    INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                         INT           NULL,
    [UserName]                     VARCHAR (100) NULL,
    [Partner_Reference]            VARCHAR (50)  NULL,
    [Partner_Tracking_Number]      VARCHAR (50)  NULL,
    [DocRetriever_Reference]       VARCHAR (50)  NULL,
    [Request]                      VARCHAR (MAX) NULL,
    [RequestDate]                  DATETIME      CONSTRAINT [DF_Table_1_RequestDate] DEFAULT (getdate()) NOT NULL,
    [refUserActionID]              INT           NULL,
    [APNO]                         INT           NULL,
    [RetrieveDocs]                 BIT           CONSTRAINT [DF_Integration_XMLRequest_RetrieveDocs] DEFAULT ((0)) NOT NULL,
    [Process_Callback_Acknowledge] BIT           CONSTRAINT [DF_Integration_OrderMgmt_Request_Process_Callback_Acknowledge] DEFAULT ((1)) NOT NULL,
    [Process_Callback_Final]       BIT           CONSTRAINT [DF_Table_1_Callback_Final_Processed] DEFAULT ((0)) NOT NULL,
    [Callback_Acknowledge_Date]    DATETIME      NULL,
    [Callback_Final_Date]          DATETIME      NULL,
    [TransformedRequest]           XML           NULL,
    [FacilityCLNO]                 INT           NULL,
    [CallbackFailures]             INT           NULL,
    [ParentRequestID]              INT           NULL,
    [ModifiedDate]                 DATE          CONSTRAINT [DF_integration_ordermgmt_request_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ClientCandidateId]            VARCHAR (100) NULL,
    [RequestCounter]               INT           NULL,
    CONSTRAINT [PK_Integration_XMLRequest] PRIMARY KEY CLUSTERED ([RequestID] ASC),
    CONSTRAINT [FK_Integration_XMLRequest_Integration_refUserAction] FOREIGN KEY ([refUserActionID]) REFERENCES [dbo].[Integration_OrderMgmt_refUserAction] ([refUserActionID])
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_Integration_OrderMgmt_Request_01]
    ON [dbo].[Integration_OrderMgmt_Request]([APNO] ASC)
    INCLUDE([RequestID]) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IDX_Integration_OrderMgmt_Request-Partner_Reference]
    ON [dbo].[Integration_OrderMgmt_Request]([Partner_Reference] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [Integration_OMR_XMLreq]
    ON [dbo].[Integration_OrderMgmt_Request]([CLNO] ASC, [RequestDate] ASC)
    INCLUDE([Request], [TransformedRequest], [APNO], [FacilityCLNO])
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_Integration_OrderMgmt_Request_RequestDate_Inc]
    ON [dbo].[Integration_OrderMgmt_Request]([RequestDate] ASC)
    INCLUDE([RequestID], [APNO], [Callback_Acknowledge_Date], [CallbackFailures], [Callback_Final_Date]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [Integration_OrderMgmt_Request_refUserActionID_CLNO_APNO]
    ON [dbo].[Integration_OrderMgmt_Request]([refUserActionID] ASC, [CLNO] ASC, [APNO] ASC)
    INCLUDE([RequestID], [UserName], [Partner_Reference], [Partner_Tracking_Number], [RequestDate], [Process_Callback_Acknowledge], [Process_Callback_Final], [Callback_Acknowledge_Date], [Callback_Final_Date], [CallbackFailures]);


GO
CREATE NONCLUSTERED INDEX [Integration_OrderMgmt_Request_refUserActionID_PCA_CAD]
    ON [dbo].[Integration_OrderMgmt_Request]([refUserActionID] ASC, [Process_Callback_Acknowledge] ASC, [Callback_Acknowledge_Date] ASC)
    INCLUDE([RequestID], [CLNO], [UserName], [Partner_Reference], [Partner_Tracking_Number], [RequestDate], [APNO], [CallbackFailures]);


GO
CREATE NONCLUSTERED INDEX [Integration_OrderMgmt_Request_PCA_CAD_refUserActionID]
    ON [dbo].[Integration_OrderMgmt_Request]([Process_Callback_Acknowledge] ASC, [Callback_Acknowledge_Date] ASC, [refUserActionID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Integration_OrderMgmt_Request_Process_Callback_Acknowledge_Process_Callback_Final]
    ON [dbo].[Integration_OrderMgmt_Request]([Process_Callback_Acknowledge] ASC, [Process_Callback_Final] ASC)
    INCLUDE([RequestID]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_Integration_OrderMgmt_Request_CLNO_ClientCandidateID]
    ON [dbo].[Integration_OrderMgmt_Request]([CLNO] ASC, [ClientCandidateId] ASC)
    INCLUDE([RequestCounter]);


GO
CREATE NONCLUSTERED INDEX [IX_Integration_OrderMgmt_Request_APNO_CLNO]
    ON [dbo].[Integration_OrderMgmt_Request]([CLNO] ASC, [APNO] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Integration_OrderMgmt_Request_ApNo_CLNO_refUserActionID]
    ON [dbo].[Integration_OrderMgmt_Request]([APNO] ASC, [CLNO] ASC, [refUserActionID] ASC)
    INCLUDE([RequestID], [Process_Callback_Acknowledge], [Callback_Acknowledge_Date]);

