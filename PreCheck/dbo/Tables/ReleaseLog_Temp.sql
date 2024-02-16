CREATE TABLE [dbo].[ReleaseLog_Temp] (
    [tempReleaselogid] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]             INT          NOT NULL,
    [DateTimeStamp]    DATETIME     CONSTRAINT [DF_DBO.ReleaseLog_Temp_DateTimeStamp] DEFAULT (getdate()) NOT NULL,
    [AppSSN]           VARCHAR (50) NULL,
    [AppDOB]           DATETIME     NULL,
    [SSN]              VARCHAR (50) NULL,
    [DOB]              VARCHAR (50) NULL,
    CONSTRAINT [PK_DBO.ReleaseLog_Temp] PRIMARY KEY CLUSTERED ([tempReleaselogid] ASC) WITH (FILLFACTOR = 50)
);

