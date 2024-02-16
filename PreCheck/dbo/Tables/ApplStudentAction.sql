CREATE TABLE [dbo].[ApplStudentAction] (
    [ApplStudentActionID]  INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                 INT          NULL,
    [CLNO_Hospital]        INT          NOT NULL,
    [StudentActionID]      INT          CONSTRAINT [DF_ApplStudentAction_StudentActionID] DEFAULT ((0)) NULL,
    [DateHospitalAssigned] DATETIME     CONSTRAINT [DF_ApplStudentAction_DateHospitalAssigned] DEFAULT (getdate()) NULL,
    [DateStatusSet]        DATETIME     NULL,
    [SSN]                  VARCHAR (11) NULL,
    [LastName]             VARCHAR (30) NULL,
    [FirstName]            VARCHAR (30) NULL,
    [IsActive]             BIT          CONSTRAINT [DF_ApplStudentAction_IsActive_1] DEFAULT ((1)) NULL,
    [OtherServiceNumber]   INT          NULL,
    [BusinessServiceId]    INT          NULL,
    [CreateDate]           DATETIME     CONSTRAINT [DF_ApplStudentAction_CreateDate] DEFAULT (getdate()) NULL,
    [CreateBy]             INT          CONSTRAINT [DF_ApplStudentAction_CreateBy] DEFAULT ((0)) NULL,
    [ModifyDate]           DATETIME     CONSTRAINT [DF_ApplStudentAction_ModifyDate] DEFAULT (getdate()) NULL,
    [ModifyBy]             INT          CONSTRAINT [DF_ApplStudentAction_ModifyBy] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ApplStudentAction] PRIMARY KEY CLUSTERED ([ApplStudentActionID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ApplStudentAction_Appl] FOREIGN KEY ([APNO]) REFERENCES [dbo].[Appl] ([APNO])
);


GO
CREATE NONCLUSTERED INDEX [IDX_ApplStudentAction_APNO-Inc]
    ON [dbo].[ApplStudentAction]([APNO] ASC)
    INCLUDE([ApplStudentActionID], [CLNO_Hospital], [StudentActionID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_ApplStudentAction_HospitalCLNO_DateAssigned_Inc]
    ON [dbo].[ApplStudentAction]([CLNO_Hospital] ASC, [DateHospitalAssigned] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [DateHospitalAssigned_Includes]
    ON [dbo].[ApplStudentAction]([DateHospitalAssigned] ASC)
    INCLUDE([APNO], [CLNO_Hospital]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IDX_IsActiveCreateDate_Includes]
    ON [dbo].[ApplStudentAction]([IsActive] ASC, [CreateDate] ASC)
    INCLUDE([APNO], [CLNO_Hospital], [StudentActionID]);


GO
CREATE NONCLUSTERED INDEX [IX_ApplStudentAction_StudentActionID_DateStatusSet]
    ON [dbo].[ApplStudentAction]([StudentActionID] ASC, [DateStatusSet] ASC)
    INCLUDE([APNO], [CLNO_Hospital], [IsActive]);


GO
CREATE TRIGGER [dbo].[HospitalActionDate] ON [dbo].[ApplStudentAction] 
FOR UPDATE

AS


if Update(StudentActionID)
     Update ApplStudentAction
         set DateStatusSet = CURRENT_TIMESTAMP--convert(varchar(10),getdate(),101)
     from ApplStudentAction inner join Deleted
    on (ApplStudentAction.ApplStudentActionID = Deleted.ApplStudentActionID)
    where (ApplStudentAction.StudentActionID <>Deleted.StudentActionID)
