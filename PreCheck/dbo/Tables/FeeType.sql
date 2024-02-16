CREATE TABLE [dbo].[FeeType] (
    [FeeTypeId]   SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Feetype]     VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (200) NULL,
    [Isactive]    BIT           NULL,
    [CreateDate]  DATETIME      NULL,
    [CreateBy]    INT           NULL,
    [ModifyDate]  DATETIME      NULL,
    [ModifyBy]    INT           NULL,
    PRIMARY KEY CLUSTERED ([FeeTypeId] ASC) ON [PRIMARY]
) ON [PRIMARY];

