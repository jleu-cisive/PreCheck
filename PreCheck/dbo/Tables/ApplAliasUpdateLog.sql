CREATE TABLE [dbo].[ApplAliasUpdateLog] (
    [apno]              INT          NOT NULL,
    [Alias1_first]      VARCHAR (50) NULL,
    [Alias1_Middle]     VARCHAR (50) NULL,
    [Alias1_Last]       VARCHAR (50) NULL,
    [Alias1_Generation] VARCHAR (3)  NULL,
    [Alias2_First]      VARCHAR (50) NULL,
    [Alias2_Middle]     VARCHAR (50) NULL,
    [Alias2_Last]       VARCHAR (50) NULL,
    [Alias2_Generation] VARCHAR (3)  NULL,
    [Alias3_first]      VARCHAR (50) NULL,
    [Alias3_Middle]     VARCHAR (50) NULL,
    [Alias3_Last]       VARCHAR (50) NULL,
    [Alias3_Generation] VARCHAR (3)  NULL,
    [Alias4_first]      VARCHAR (50) NULL,
    [Alias4_Middle]     VARCHAR (50) NULL,
    [Alias4_Last]       VARCHAR (50) NULL,
    [Alias4_Generation] VARCHAR (3)  NULL,
    [createddate]       DATETIME     DEFAULT (getdate()) NULL
);

