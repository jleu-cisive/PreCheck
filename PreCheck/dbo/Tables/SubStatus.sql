CREATE TABLE [dbo].[SubStatus] (
    [SubStatusID]      INT          IDENTITY (1, 1) NOT NULL,
    [MainStatusID]     INT          NULL,
    [SubStatus]        VARCHAR (50) NULL,
    [WaitTimeInMinute] INT          CONSTRAINT [DF_SubStatus_WaitTimeInMinute] DEFAULT ((0)) NULL,
    [PriorityLevel]    INT          NULL,
    [IsActive]         BIT          CONSTRAINT [DF_SubStatus_IsActive] DEFAULT ((0)) NULL,
    [IsVerifyStatus]   BIT          CONSTRAINT [DF_SubStatus_IsVerifyStatus] DEFAULT ((0)) NULL,
    [IsAll]            BIT          CONSTRAINT [DF_SubStatus_IsAll] DEFAULT ((0)) NULL,
    [IsCS]             BIT          CONSTRAINT [DF_SubStatus_IsCS] DEFAULT ((0)) NULL,
    [IsEmpl]           BIT          CONSTRAINT [DF_SubStatus_IsEmpl] DEFAULT ((0)) NULL,
    [IsEducat]         BIT          CONSTRAINT [DF_SubStatus_IsEducat] DEFAULT ((0)) NULL,
    [IsPersRef]        BIT          CONSTRAINT [DF_SubStatus_IsPersRef] DEFAULT ((0)) NULL,
    [IsProfLic]        BIT          CONSTRAINT [DF_SubStatus_IsProfLic] DEFAULT ((0)) NULL,
    [IsCrim]           BIT          CONSTRAINT [DF_SubStatus_IsCrim] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_SubStatus] PRIMARY KEY CLUSTERED ([SubStatusID] ASC) WITH (FILLFACTOR = 50)
);

