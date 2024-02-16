CREATE TABLE [dbo].[IntellicorpEnum] (
    [ID]    INT          IDENTITY (1, 1) NOT NULL,
    [Type]  VARCHAR (40) NOT NULL,
    [Code]  VARCHAR (40) NOT NULL,
    [Value] INT          NULL
) ON [PRIMARY];

