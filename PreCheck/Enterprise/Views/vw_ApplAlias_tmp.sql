

CREATE VIEW enterprise.[vw_ApplAlias_tmp]
AS
SELECT ROW_NUMBER() over (partition by S.ApplicantID,'U' order by S.ApplicantId,S.ApplicantAliasID) RowNum, 
		 S.ApplicantId APNO1
		 ,S.[ApplicantAliasID]
		 ,S.[ApplicantId]
		  ,CONVERT(VARCHAR(50),S.[FirstName]) [First]
		  ,CONVERT(VARCHAR(50),S.[MiddleName]) [Middle]
		  ,CONVERT(VARCHAR(50),S.[LastName]) [Last]
		  ,S.CreateDate
		  ,CONVERT(VARCHAR(25),S.CreateBy) [Addedby] , 'U' Operation
	FROM  Enterprise..ApplicantAlias S;


