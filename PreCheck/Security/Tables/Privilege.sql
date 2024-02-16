CREATE TABLE [Security].[Privilege] (
    [PrivilegeId]     INT      IDENTITY (1, 1) NOT NULL,
    [PrincipalTypeId] INT      NOT NULL,
    [PrincipalId]     INT      NOT NULL,
    [ResourceTypeId]  INT      NOT NULL,
    [ResourceId]      INT      NOT NULL,
    [AccessTypeId]    INT      NULL,
    [AccessId]        INT      NULL,
    [IsActive]        BIT      CONSTRAINT [DF_Privilege_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]      DATETIME CONSTRAINT [DF_Privilege_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]        INT      CONSTRAINT [DF_Privilege_CreateBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]      DATETIME CONSTRAINT [DF_Privilege_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]        INT      CONSTRAINT [DF_Privilege_ModifyBy] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Privilege] PRIMARY KEY CLUSTERED ([PrivilegeId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY],
    CONSTRAINT [FK_Privilege_AccessType] FOREIGN KEY ([AccessTypeId]) REFERENCES [Security].[AccessType] ([AccessTypeId]),
    CONSTRAINT [FK_Privilege_PrincipalType] FOREIGN KEY ([PrincipalTypeId]) REFERENCES [Security].[PrincipalType] ([PrincipalTypeId]),
    CONSTRAINT [FK_Privilege_ResourceType] FOREIGN KEY ([ResourceTypeId]) REFERENCES [Security].[ResourceType] ([ResourceTypeId])
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [PrincipalTypeId_PrincipalId_ResourceTypeId]
    ON [Security].[Privilege]([PrincipalTypeId] ASC, [PrincipalId] ASC, [ResourceTypeId] ASC) WITH (FILLFACTOR = 100)
    ON [PRIMARY];

