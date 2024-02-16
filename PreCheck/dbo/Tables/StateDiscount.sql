CREATE TABLE [dbo].[StateDiscount] (
    [StateDiscountID]      INT           IDENTITY (1, 1) NOT NULL,
    [State]                NVARCHAR (20) NULL,
    [StudentCheckDiscount] MONEY         NULL,
    CONSTRAINT [PK_StateDiscount] PRIMARY KEY CLUSTERED ([StateDiscountID] ASC) WITH (FILLFACTOR = 50)
);

