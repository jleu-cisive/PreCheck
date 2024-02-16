
CREATE VIEW [STG].[vw_ApplAlias_CT]
AS
SELECT ROW_NUMBER() over (partition by S.APNO,Operation order by S.APNO,S.ApplicantAliasID) RowNum, 
		 S.[APNO]
		 ,S.[ApplicantAliasID]
		 ,S.[ApplicantId]
		  ,CONVERT(VARCHAR(50),S.[First]) [First]
		  ,CONVERT(VARCHAR(50),S.[Middle]) [Middle]
		  ,CONVERT(VARCHAR(50),S.[Last]) [Last]
		  ,S.[CreatedDate]
		  ,CONVERT(VARCHAR(25),S.[AddedBy]) [Addedby] , Operation
	FROM  [STG].[ApplAlias_CT] S;


