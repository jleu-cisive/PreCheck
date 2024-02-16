CREATE TABLE [dbo].[MainStatus] (
    [MainStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [MainStatus]   VARCHAR (25) NULL,
    [IsActive]     BIT          CONSTRAINT [DF_MainStatus_IsActive] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_MainStatus] PRIMARY KEY CLUSTERED ([MainStatusID] ASC) WITH (FILLFACTOR = 50)
);

