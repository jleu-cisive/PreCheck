CREATE TABLE [dbo].[ClientOutOfBusiness] (
    [ClientOutOfBusinessId] INT            IDENTITY (1, 1) NOT NULL,
    [ClientName]            NVARCHAR (100) NULL,
    [CLNO]                  SMALLINT       NOT NULL,
    [IsActive]              BIT            CONSTRAINT [DF_ClientOutOfBusiness_isActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]            DATETIME       CONSTRAINT [DF_ClientOutOfBusiness_createdDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]             NVARCHAR (100) NULL,
    [ModifyDate]            DATETIME       NULL,
    [ModifyBy]              NVARCHAR (100) NULL,
    CONSTRAINT [PK_ClientOutOfBusiness] PRIMARY KEY CLUSTERED ([ClientOutOfBusinessId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_ClientOutOfBusiness_Client] FOREIGN KEY ([CLNO]) REFERENCES [dbo].[Client] ([CLNO])
);

