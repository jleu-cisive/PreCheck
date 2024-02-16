CREATE TABLE [dbo].[Integration_PrecheckCallback] (
    [PrecheckCallbackID]           INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                         INT          NOT NULL,
    [FacilityCLNO]                 INT          NULL,
    [APNO]                         INT          NOT NULL,
    [Partner_Reference]            VARCHAR (50) NOT NULL,
    [Process_Callback_Acknowledge] BIT          CONSTRAINT [DF_Integration_PrecheckCallback_Process_Callback_Acknowledge] DEFAULT ((1)) NOT NULL,
    [Process_Callback_Final]       BIT          CONSTRAINT [DF_Integration_PrecheckCallback_Process_Callback_Final] DEFAULT ((0)) NOT NULL,
    [Callback_Acknowledge_Date]    DATETIME     NULL,
    [Callback_Final_Date]          DATETIME     NULL,
    [CallbackFailures]             INT          CONSTRAINT [DF_Integration_PrecheckCallback_CallbackFailures] DEFAULT ((0)) NOT NULL,
    [CreatedDate]                  DATETIME     CONSTRAINT [DF_Integration_PrecheckCallback_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Integration_PrecheckCallback] PRIMARY KEY CLUSTERED ([PrecheckCallbackID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Integration_PrecheckCallback_CallbackFailures_CreatedDate_Inc]
    ON [dbo].[Integration_PrecheckCallback]([CallbackFailures] ASC, [CreatedDate] ASC)
    INCLUDE([PrecheckCallbackID], [APNO], [Callback_Acknowledge_Date]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [APNO]
    ON [dbo].[Integration_PrecheckCallback]([APNO] ASC) WITH (FILLFACTOR = 100);

