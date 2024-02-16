-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 05/15/2018
-- Description:	Insert ApplAlias_Sections table only when the combination of (CrimID & ApplAliasID) DO NOT EXIST
-- Execution:	EXEC Insert_Update_ApplAliasSelections 2676299,1,26395917,3151770,'dvodethe'
--				EXEC Insert_Update_ApplAliasSelections 2676299,1,26395917,NULL,'dvodethe'
-- =============================================
CREATE PROCEDURE [dbo].[Insert_Update_ApplAliasSelections] 
	-- Add the parameters for the stored procedure here
	@ApplAliasID int = NULL,
	@IsActive bit = NULL,
	@AliasCrimID int = NULL,
	@ApplAlias_SectionID int = NULL,
	@Investigator varchar(8) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Update existing records IsActive status
	IF ISNULL(@ApplAlias_SectionID,0)>0 
	BEGIN
		UPDATE ApplAlias_Sections 
			SET IsActive = @IsActive, 
				LastUpdateDate = CURRENT_TIMESTAMP, 
				LastUpdatedBy = @Investigator 
			WHERE ApplAlias_SectionID = @ApplAlias_SectionID
	END

	-- Insert into ApplAlias_Sections only when the combination of (CrimID & ApplAliasID) DO NOT EXIST
	IF ((SELECT COUNT(1) FROM dbo.ApplAlias_Sections AS S(NOLOCK) WHERE S.SectionKeyID = @AliasCrimID AND S.ApplAliasID = @ApplAliasID) = 0)
	BEGIN
		INSERT INTO [dbo].[ApplAlias_Sections]
					([ApplSectionID]
					,[SectionKeyID]
					,[ApplAliasID]
					,[IsActive]
					,[CreateDate]
					,[CreatedBy]
					,[LastUpdateDate]
					,[LastUpdatedBy])
				VALUES
					(5
					,@AliasCrimID
					,@ApplAliasID
					,@IsActive
					,CURRENT_TIMESTAMP
					,@Investigator
					,CURRENT_TIMESTAMP
					,@Investigator)
		END
END
