CREATE TABLE [dbo].[PrecheckCost] (
    [CostID]     INT         IDENTITY (1, 1) NOT NULL,
    [Month]      VARCHAR (2) NULL,
    [Year]       VARCHAR (4) NULL,
    [SSN]        MONEY       NULL,
    [Medicare]   MONEY       NULL,
    [Credit]     MONEY       NULL,
    [Employment] MONEY       NULL,
    [Personal]   MONEY       NULL,
    [License]    MONEY       NULL,
    [Education]  MONEY       NULL,
    [Criminal]   MONEY       NULL,
    [FixedCost]  MONEY       NULL,
    CONSTRAINT [PK_PrecheckCost] PRIMARY KEY CLUSTERED ([CostID] ASC) WITH (FILLFACTOR = 50)
);

