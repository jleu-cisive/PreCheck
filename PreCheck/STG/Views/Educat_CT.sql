





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [STG].[Educat_CT] 
AS
SELECT  [ApplicantEducationId]  [EducatID]
      , ApplicantNumber  [APNO]
      ,[SchoolName]  [School]
      ,NULL [SectStat]
      ,NULL [Worksheet]
      ,[State]  [State]
      ,NULL [Phone]
      ,[DegreeName]  [Degree_A]
       ,[Major] [Studies_A]
      ,[AttendedFrom]  [From_A]
      ,[AttendedTo] [To_A]
      ,[NameOnDegree]  [Name]
      ,NULL [Degree_V]
      ,NULL [Studies_V]
      ,NULL [From_V]
      ,NULL [To_V]
      ,NULL [Contact_Name]
      ,NULL [Contact_Title]
      ,NULL [Contact_Date]
      ,NULL [Investigator]
      ,NULL [Priv_Notes]
      ,NULL [Pub_Notes]
      ,NULL [web_status]
      ,NULL [includealias]
      ,NULL [includealias2]
      ,NULL [includealias3]
      ,NULL [includealias4]
      ,NULL [pendingupdated]
      ,NULL [web_updated]
      ,NULL [Time_In]
      ,[ModifyDate] [Last_Updated]
      ,[City]  [city]
      ,NULL [zipcode]
      ,[CampusName]  [CampusName]
      ,NULL [InUse]
      , [CreateDate]  [CreatedDate]
      ,NULL [ToPending]
      ,NULL [FromPending]
      ,NULL [Completed]
      ,NULL [Last_Worked]
      ,NULL [SchoolID]
      ,NULL [IsCAMReview]
      ,NULL [IsOnReport]
      ,NULL [IsHidden]
      ,NULL [IsHistoryRecord]
      ,ISNULL([IsGraduated],0) [HasGraduated]
      ,NULL  [HighestCompleted]
      ,NULL [EducatVerifyID]
      ,NULL [GetNextDate]
      ,NULL [SubStatusID]
      ,NULL [ClientAdjudicationStatus]
      ,NULL [ClientRefID]
      ,CASE WHEN Country IN ('USA','US','America','States', 'United States') THEN 0 ELSE 1 END [IsIntl]
      ,NULL [DateOrdered]
      ,NULL [OrderId]
      ,NULL [InUse_TimeStamp]
      ,NULL [LastModifiedDate]
      ,NULL [LastModifiedBy]
	  ,[GraduationYear] [GraduationYear] --Added by Humera Ahmed for Change#71 on 08/12/2021
	  ,Operation
  FROM [STG].[ApplicantEducation_CT]





