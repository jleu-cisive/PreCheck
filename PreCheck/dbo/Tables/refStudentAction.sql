CREATE TABLE [dbo].[refStudentAction] (
    [StudentActionID] INT          CONSTRAINT [DF_refActionID_ActionID] DEFAULT (0) NOT NULL,
    [StudentAction]   VARCHAR (50) CONSTRAINT [DF_refActionID_ActionName] DEFAULT ('Not Reviewed') NOT NULL,
    [DisplayOrder]    INT          CONSTRAINT [DF_refStudentAction_DisplayOrder] DEFAULT (0) NOT NULL,
    [IsActive]        BIT          CONSTRAINT [DF_refStudentAction_IsActive] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_refActionID] PRIMARY KEY CLUSTERED ([StudentActionID] ASC) WITH (FILLFACTOR = 50)
);

