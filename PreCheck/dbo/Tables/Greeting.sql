CREATE TABLE [dbo].[Greeting] (
    [GreetingID] INT            IDENTITY (1, 1) NOT NULL,
    [Greeting]   VARCHAR (MAX)  NULL,
    [Holiday]    VARCHAR (8000) NULL,
    CONSTRAINT [PK_Greeting] PRIMARY KEY CLUSTERED ([GreetingID] ASC) WITH (FILLFACTOR = 50)
);

