
/*
Created By	:	Larry Ouch
Created Date:	02/07//2017
Description	:	Grabs all ApplAlias and ApplAlias_Section records per apno.
Execution	:	EXEC [dbo].[Iris_GetApplAlias]  6800845, 35057783
--Modified by Humera Ahmed on 2/13/2023 to include PreClear results for HDT 59751 - Allowing for vendor to submit court fees and Jira ticket CXHE-11
*/
CREATE PROCEDURE [dbo].[Iris_GetApplAlias](
@apno INT,
@crimid INT
)
AS
SET NOCOUNT ON  
BEGIN
	CREATE TABLE #tblAliasList
	(
		APNO INT,
		ApplAliasID INT,
		[First] VARCHAR(50),
		Middle VARCHAR(50),
		[Last] VARCHAR(50),
		Generation VARCHAR(15),
		IsPublicRecordQualified BIT,
		IsPrimaryName BIT,
		AAIsActive BIT,
		ApplAlias_SectionID INT,
		ApplSectionID INT,
		CrimID INT,
		AASApplAliasID INT,
		AASIsActive INT,
		[PreClearResult] varchar(1000)
	)

	INSERT INTO #tblAliasList
	SELECT	AA.APNO, MIN(AA.ApplAliasID) ApplAliasID, AA.First, ISNULL(Middle,'') Middle, AA.Last, ISNULL(Generation,'') Generation, MAX(CAST(IsPublicRecordQualified as int)) IsPublicRecordQualified, MAX(CAST(AA.IsPrimaryName as int)) IsPrimaryName,
			MAX(CAST(AA.IsActive as int))  AS AAIsActive, MIN(AAS.ApplAlias_SectionID) ApplAlias_SectionID, MIN(AAS.ApplSectionID) ApplSectionID, AAS.SectionKeyID AS CrimID, MIN(AAS.ApplAliasID) AS AASApplAliasID, MAX(CAST(AAS.IsActive as int)) AS AASIsActive
			--, isnull(CAST(pl.Request AS XML).value('(Request/Results/Result/OrderResult)[1]', 'varchar(100)'), 'N.A.')as [PreClearResult]
			,case when CAST(pl.Request AS XML).value('(Request/Results/Result/OrderResult)[1]', 'varchar(100)') is null then 'N.A.' 
				  when CAST(pl.Request AS XML).value('(Request/Results/Result/OrderResult)[1]', 'varchar(100)') = 'Review' then 'Possible Hit'
				  else CAST(pl.Request AS XML).value('(Request/Results/Result/OrderResult)[1]', 'varchar(100)')
			end as [PreClearResult]
	--INTO #tblAliasList
	FROM ApplAlias AS AA(NOLOCK)
	LEFT OUTER JOIN ApplAlias_Sections AS AAS(NOLOCK) ON AA.ApplAliasID = AAS.ApplAliasID AND AAS.SectionKeyID = @crimid
	LEFT OUTER JOIN Partner_Log pl on pl.sectionid = @crimid and AA.ApplAliasID = pl.applaliasid and isjson(pl.Request)=0
	WHERE AA.APNO = @apno and AA.IsActive = 1 
	GROUP BY AA.APNO,First,ISNULL(Middle,''),Last,ISNULL(Generation,''), AAS.SectionKeyID, pl.Request

	SELECT  APNO, ApplAliasID, First, Middle, Last, Generation, CAST(IsPublicRecordQualified as bit) IsPublicRecordQualified, CAST(IsPrimaryName as bit) IsPrimaryName, CAST(AAIsActive as Bit) AAIsActive, ApplAlias_SectionID,
			ApplSectionID, CrimID, AASApplAliasID, CAST(AASIsActive as bit) AASIsActive, [PreClearResult]
	FROM #tblAliasList
	ORDER BY IsPrimaryName DESC, IsPublicRecordQualified DESC

	DROP TABLE #tblAliasList

END

