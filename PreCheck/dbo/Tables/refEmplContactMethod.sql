CREATE TABLE [dbo].[refEmplContactMethod] (
    [refEmplContactMethodID] INT          IDENTITY (1, 1) NOT NULL,
    [ComboOrder]             INT          NULL,
    [KeyName]                VARCHAR (4)  NULL,
    [Translation]            VARCHAR (30) NULL,
    CONSTRAINT [PK_refEmplContactMethod] PRIMARY KEY CLUSTERED ([refEmplContactMethodID] ASC) WITH (FILLFACTOR = 50)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Value is ComboOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'refEmplContactMethod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'VALUE BEING USED BY CLIENTEMPLOYER', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'refEmplContactMethod', @level2type = N'COLUMN', @level2name = N'ComboOrder';

