CREATE TABLE [dbo].[refEmployees] (
    [EmployeeID] INT           IDENTITY (1, 1) NOT NULL,
    [Employee]   NVARCHAR (50) NULL,
    [UserID]     VARCHAR (8)   NULL,
    CONSTRAINT [PK_refEmployees] PRIMARY KEY CLUSTERED ([EmployeeID] ASC) WITH (FILLFACTOR = 50)
);

