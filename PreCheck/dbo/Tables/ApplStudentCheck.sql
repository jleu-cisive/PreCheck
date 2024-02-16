CREATE TABLE [dbo].[ApplStudentCheck] (
    [APNOStudentCheck]   INT           NOT NULL,
    [IsHidden]           BIT           NOT NULL,
    [HideUnHideDateTime] DATETIME      NOT NULL,
    [UserID]             VARCHAR (200) NULL,
    CONSTRAINT [PK_AppStudentCheck] PRIMARY KEY CLUSTERED ([APNOStudentCheck] ASC) WITH (FILLFACTOR = 50)
);

