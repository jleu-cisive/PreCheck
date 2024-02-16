CREATE TABLE [dbo].[I9RequestType] (
    [I9RequestTypeId] INT            IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (150) NOT NULL,
    [Description]     NVARCHAR (250) NULL,
    [CreateDate]      DATETIME       NOT NULL,
    [CreateBy]        NVARCHAR (50)  NULL,
    [ModifyDate]      DATETIME       NULL,
    [ModifyBy]        NVARCHAR (50)  NULL,
    CONSTRAINT [PK_dbo.I9RequestType] PRIMARY KEY CLUSTERED ([I9RequestTypeId] ASC)
);

