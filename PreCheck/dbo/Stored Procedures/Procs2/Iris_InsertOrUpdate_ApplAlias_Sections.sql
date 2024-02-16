/*
Created By	:	Larry Ouch
Created Date:	05/15/2017
Description	:	Inserts or Updates an ApplAlias_Sections record based on the parameteres.
Execution	:	EXEC [dbo].[Iris_InsertOrUpdate_ApplAlias_Sections]  23402890, 999279, 1, 'test'
*/
CREATE PROCEDURE [dbo].[Iris_InsertOrUpdate_ApplAlias_Sections]
@crimId INT,
@applAliasId INT,
@isActive BIT,
@investigator VARCHAR(8)

AS

	DECLARE @applalias_sectionid INT

	SET @applalias_sectionid = 
		(SELECT applalias_sectionid 
		FROM ApplAlias_Sections 
		WHERE ApplAliasID = @applaliasid 
		  AND SectionKeyID = @crimId
		  AND ApplSectionid = 5)

	IF(@applalias_sectionid > 0)
	BEGIN
		UPDATE ApplAlias_Sections 
		SET IsActive = @isActive, LastUpdatedBy = @investigator, LastUpdateDate = CURRENT_TIMESTAMP
		WHERE ApplAliasID = @applAliasId AND ApplAlias_SectionID = @applalias_sectionid
	END
	ELSE 
	BEGIN
		INSERT INTO ApplAlias_Sections(ApplSectionID, SectionKeyID, ApplAliasID, IsActive, CreateDate, CreatedBy, LastUpdateDate, LastUpdatedBy)
		VALUES (5, @crimId, @applAliasId, @isActive, CURRENT_TIMESTAMP, @investigator, CURRENT_TIMESTAMP, @investigator)
	END

