CREATE TABLE [dbo].[tmpHCA] (
    [RequestID]                    INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                         INT           NULL,
    [UserName]                     VARCHAR (50)  NULL,
    [Partner_Reference]            VARCHAR (50)  NULL,
    [Partner_Tracking_Number]      VARCHAR (50)  NULL,
    [DocRetriever_Reference]       VARCHAR (50)  NULL,
    [Request]                      VARCHAR (MAX) NULL,
    [RequestDate]                  DATETIME      NOT NULL,
    [refUserActionID]              INT           NULL,
    [APNO]                         INT           NULL,
    [RetrieveDocs]                 BIT           NOT NULL,
    [Process_Callback_Acknowledge] BIT           NOT NULL,
    [Process_Callback_Final]       BIT           NOT NULL,
    [Callback_Acknowledge_Date]    DATETIME      NULL,
    [Callback_Final_Date]          DATETIME      NULL,
    [TransformedRequest]           XML           NULL,
    [FacilityCLNO]                 INT           NULL,
    [CallbackFailures]             INT           NULL
);

