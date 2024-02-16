CREATE TABLE [dbo].[refEmployment] (
    [EmploymentID] INT           IDENTITY (1, 1) NOT NULL,
    [Employment]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refEmployment] PRIMARY KEY CLUSTERED ([EmploymentID] ASC) WITH (FILLFACTOR = 50)
);

