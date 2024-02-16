CREATE TABLE [dbo].[zzbkup_refClientConfiguration_092222] (
    [Key]          VARCHAR (50)   NOT NULL,
    [GroupType]    VARCHAR (50)   NOT NULL,
    [Values]       VARCHAR (MAX)  NOT NULL,
    [DisplayName]  VARCHAR (100)  NULL,
    [TableName]    VARCHAR (50)   NOT NULL,
    [ValueType]    VARCHAR (50)   NULL,
    [Description]  VARCHAR (1000) NULL,
    [DefaultValue] VARCHAR (MAX)  NULL,
    [MaxLenght]    INT            NULL,
    [IsReadOnly]   BIT            NULL
);

