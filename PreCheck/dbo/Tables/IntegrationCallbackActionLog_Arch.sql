CREATE TABLE [dbo].[IntegrationCallbackActionLog_Arch] (
    [IntegrationCallbackActionLogId] INT           IDENTITY (1, 1) NOT NULL,
    [RequestID]                      INT           NOT NULL,
    [Old_refUserActionID]            INT           NULL,
    [New_refUserActionID]            INT           NULL,
    [ChangeDate]                     DATETIME      NOT NULL,
    [Status]                         VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_IntegrationCallbackActionLog] PRIMARY KEY CLUSTERED ([IntegrationCallbackActionLogId] ASC) ON [PRIMARY]
) ON [PRIMARY];

