CREATE TABLE [dbo].[BusinessServiceBehavior] (
    [BusinessServiceBehaviorId] INT           IDENTITY (1, 1) NOT NULL,
    [RefPackageTypeId]          INT           NOT NULL,
    [BehaviorName]              VARCHAR (50)  NOT NULL,
    [BehaviorDescription]       VARCHAR (100) NOT NULL,
    [IsClientSelectable]        BIT           NOT NULL,
    [CreateDate]                DATETIME      CONSTRAINT [DF_BusinessServiceBehavior_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                  VARCHAR (50)  NOT NULL,
    [ModifyDate]                DATETIME      CONSTRAINT [DF_BusinessServiceBehavior_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]                  VARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_BusinessServiceBehavior] PRIMARY KEY CLUSTERED ([BusinessServiceBehaviorId] ASC) WITH (FILLFACTOR = 70)
);

