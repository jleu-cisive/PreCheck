CREATE TABLE [dbo].[Department] (
    [DepartmentID] INT            IDENTITY (1, 1) NOT NULL,
    [Department]   VARCHAR (50)   NOT NULL,
    [Description]  VARCHAR (1000) NULL,
    [IsActive]     BIT            CONSTRAINT [DF_Department_IsActive] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED ([DepartmentID] ASC) WITH (FILLFACTOR = 50)
);

