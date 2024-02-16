

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE  VIEW [STG].[ApplicantCrim_CT]   
AS
SELECT A.ApplicantNumber AS [APNO]      
      ,CH.[City]
      ,CH.[State]
      ,CH.[Country]
      ,CH.[OffenseDate] AS [CrimDate]
      ,CH.[OffenseDescription] AS Offense
	  ,'Enterprise' As [Source]
	  , A.SocialNumber AS [SSN]
	  , NULL AS CLNO
      ,CH.[CreateDate]
	  ,CH.Operation
  FROM [STG].[ApplicantCriminalHistory_CT] CH INNER JOIN [STG].[Applicant_CT] A
  ON A.[ApplicantId] = CH.[ApplicantId] --AND A.Operation = CH.Operation 




