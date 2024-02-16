CREATE TABLE [Security].[PrivilegeHistory] (
    [PrivilegeHistoryId] INT      IDENTITY (1, 1) NOT NULL,
    [PrivilegeId]        INT      NOT NULL,
    [PrincipalTypeId]    INT      NOT NULL,
    [PrincipalId]        INT      NOT NULL,
    [ResourceTypeId]     INT      NOT NULL,
    [ResourceId]         INT      NOT NULL,
    [AccessTypeId]       INT      NULL,
    [AccessId]           INT      NULL,
    [IsActive]           BIT      CONSTRAINT [DF_PrivilegeHistory_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]         DATETIME CONSTRAINT [DF_PrivilegeHistory_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]           INT      CONSTRAINT [DF_PrivilegeHistory_CreateBy] DEFAULT ('CM') NOT NULL,
    [ModifyDate]         DATETIME NOT NULL,
    [ModifyBy]           INT      NOT NULL,
    CONSTRAINT [PK_PrivilegeHistory] PRIMARY KEY CLUSTERED ([PrivilegeHistoryId] ASC) ON [PRIMARY]
) ON [PRIMARY];

