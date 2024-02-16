CREATE TABLE [dbo].[OCHS_CandidateSchedule] (
    [OCHS_CandidateScheduleID] INT          IDENTITY (1, 1) NOT NULL,
    [OCHS_CandidateID]         INT          NOT NULL,
    [ExpirationDate]           DATETIME     NOT NULL,
    [CreatedDate]              DATETIME     NOT NULL,
    [CreatedBy]                VARCHAR (50) NOT NULL,
    [ScheduledByID]            INT          NULL,
    [IsValidLink]              BIT          NULL,
    [LastModifiedDate]         DATETIME     CONSTRAINT [DF_OCHS_CandidateSchedule_LastModifiedDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_oCHS_CandidateSchedule] PRIMARY KEY CLUSTERED ([OCHS_CandidateScheduleID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [IDX_OCHS_CandidateSchedule_IsValidLink_ExpirationDate_Inc]
    ON [dbo].[OCHS_CandidateSchedule]([IsValidLink] ASC, [ExpirationDate] ASC)
    INCLUDE([OCHS_CandidateScheduleID], [OCHS_CandidateID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_OCHS_CandidateSchedule_OCHS_CandidateID]
    ON [dbo].[OCHS_CandidateSchedule]([OCHS_CandidateID] ASC) WITH (FILLFACTOR = 70);

