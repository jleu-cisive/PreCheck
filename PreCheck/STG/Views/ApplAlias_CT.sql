
CREATE  VIEW [STG].[ApplAlias_CT]
as
SELECT DISTINCT   [ApplicantAliasID]
      ,AA.ApplicantNumber [APNO]
	  ,AA.ApplicantId [ApplicantId]
      ,AA.[FirstName] [First]
      ,AA.[MiddleName] [Middle]
      ,AA.[LastName] [Last]
      ,Null [IsMaiden]
      ,AA.[CreateDate] [CreatedDate]
      ,Null [Generation]
      ,AA.[CreateBy] [AddedBy]
      ,Null [CLNO]
      ,Null [SSN]
      ,AA.[Operation]
FROM [STG].[ApplicantAlias_CT] AA INNER JOIN [STG].[Applicant_CT] A
ON A.ApplicantId = AA.ApplicantId


