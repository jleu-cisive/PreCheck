CREATE TABLE [dbo].[IntegrationCallbackActionLog] (
    [IntegrationCallbackActionLogId] INT           IDENTITY (1, 1) NOT NULL,
    [RequestID]                      INT           NOT NULL,
    [Old_refUserActionID]            INT           NULL,
    [New_refUserActionID]            INT           NULL,
    [ChangeDate]                     DATETIME      NOT NULL,
    [Status]                         VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_IntegrationCallbackActionLog_New] PRIMARY KEY CLUSTERED ([IntegrationCallbackActionLogId] ASC) ON [PRIMARY]
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_IntegrationCallbackActionLog_New_RequestID]
    ON [dbo].[IntegrationCallbackActionLog]([RequestID] ASC)
    ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_IntegrationCallbackActionLog_New_ChangeDate]
    ON [dbo].[IntegrationCallbackActionLog]([ChangeDate] ASC)
    ON [PRIMARY];

