CREATE TABLE [dbo].[DatabaseObjectError] (
    [DatabaseObjectErrorId] INT            IDENTITY (1, 1) NOT NULL,
    [ErrorNumber]           INT            NULL,
    [ErrorState]            INT            NULL,
    [ErrorSeverity]         INT            NULL,
    [ErrorProcedure]        NVARCHAR (128) NULL,
    [ErrorLine]             INT            NULL,
    [ErrorMessage]          VARCHAR (MAX)  NULL,
    [CreateDate]            DATETIME       NULL,
    [CreateBy]              VARCHAR (200)  NULL,
    CONSTRAINT [PK_DatabaseObjectError] PRIMARY KEY CLUSTERED ([DatabaseObjectErrorId] ASC)
);

