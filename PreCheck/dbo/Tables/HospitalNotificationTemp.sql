CREATE TABLE [dbo].[HospitalNotificationTemp] (
    [HospitalNotificationTempID] INT           IDENTITY (1, 1) NOT NULL,
    [HospitalID]                 INT           NOT NULL,
    [AppCount]                   INT           NULL,
    [SchoolName]                 VARCHAR (50)  NULL,
    [To]                         VARCHAR (50)  NULL,
    [From]                       VARCHAR (50)  NULL,
    [Body]                       VARCHAR (500) NULL,
    [Subject]                    VARCHAR (100) NULL,
    CONSTRAINT [PK_HospitalNotificationTemp] PRIMARY KEY CLUSTERED ([HospitalNotificationTempID] ASC) WITH (FILLFACTOR = 50)
);

