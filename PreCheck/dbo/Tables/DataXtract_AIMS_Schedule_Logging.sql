CREATE TABLE [dbo].[DataXtract_AIMS_Schedule_Logging] (
    [DataXtract_AIMS_ScheduleID_LoggingId] INT           IDENTITY (1, 1) NOT NULL,
    [DataXtract_AIMS_ScheduleID]           INT           NOT NULL,
    [DataXtract_RequestMappingXMLID]       INT           NOT NULL,
    [refAIMS_SectionTypeCode]              VARCHAR (10)  NOT NULL,
    [NextRunTime]                          DATETIME      NOT NULL,
    [Interval]                             VARCHAR (50)  NOT NULL,
    [TimeValue]                            INT           NOT NULL,
    [IsActive]                             BIT           NOT NULL,
    [VendorAccountId]                      INT           NOT NULL,
    [CreatedBy]                            VARCHAR (100) NOT NULL,
    [CreatedDate]                          DATETIME      NOT NULL,
    [ModifiedBy]                           VARCHAR (100) NOT NULL,
    [ModifiedDate]                         DATETIME      NOT NULL,
    CONSTRAINT [PK_DataXtract_AIMS_ScheduleID_LoggingId] PRIMARY KEY CLUSTERED ([DataXtract_AIMS_ScheduleID_LoggingId] ASC),
    CONSTRAINT [FK_DataXtract_AIMS_ScheduleID_Logging] FOREIGN KEY ([DataXtract_AIMS_ScheduleID]) REFERENCES [dbo].[DataXtract_AIMS_Schedule] ([DataXtract_AIMS_ScheduleID]),
    CONSTRAINT [FK_DataXtract_RequestMappingXMLID_Logging] FOREIGN KEY ([DataXtract_RequestMappingXMLID]) REFERENCES [dbo].[DataXtract_RequestMapping] ([DataXtract_RequestMappingXMLID]),
    CONSTRAINT [FK_refAIMS_SectionTypeCode_Logging] FOREIGN KEY ([refAIMS_SectionTypeCode]) REFERENCES [dbo].[refAIMS_SectionType] ([refAIMS_SectionTypeCode])
);

