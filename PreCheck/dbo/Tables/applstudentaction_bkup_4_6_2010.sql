CREATE TABLE [dbo].[applstudentaction_bkup_4_6_2010] (
    [ApplStudentActionID]  INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                 INT          NULL,
    [CLNO_Hospital]        INT          NOT NULL,
    [StudentActionID]      INT          NULL,
    [DateHospitalAssigned] DATETIME     NULL,
    [DateStatusSet]        DATETIME     NULL,
    [SSN]                  VARCHAR (11) NULL,
    [LastName]             VARCHAR (30) NULL,
    [FirstName]            VARCHAR (30) NULL,
    [IsActive]             BIT          NULL
) ON [PRIMARY];

