CREATE PROCEDURE InUseSectionSet @TableName varchar(50), @TableID int, @UserID varchar(8) AS

DECLARE @InUse varchar(8)

if @TableName = 'Appl'
	SELECT @InUse=InUse FROM Appl WHERE APNO=@TableID
else if @TableName = 'Empl'
	SELECT @InUse=InUse FROM Empl WHERE EmplID=@TableID
else if @TableName = 'Educat'
	SELECT @InUse=InUse FROM Educat WHERE EducatID=@TableID
else if @TableName = 'ProfLic'
	SELECT @InUse=InUse FROM ProfLic WHERE ProfLicID=@TableID
else if @TableName = 'PersRef'
	SELECT @InUse=InUse FROM PersRef WHERE PersRefID=@TableID
else if @TableName = 'Crim'
	SELECT @InUse=InUse FROM Cim WHERE CrimID=@TableID   -- required change to Crim table InUse bit --> InUse varchar(8)
else if @TableName = 'Civil'
	SELECT @InUse=InUse FROM Civil WHERE CivilID=@TableID
else if @TableName = 'MedInteg'
	SELECT @InUse=InUse FROM MedInteg WHERE APNO=@TableID  --should have its own ID
else if @TableName = 'DL'
	SELECT @InUse=InUse FROM DL WHERE APNO=@TableID  --should have its own ID
else if @TableName='Credit' --  & Social
	SELECT @InUse=InUse FROM Credit WHERE APNO=@TableID  --should have its own ID
--else-
  --bad TableName

	if(@InUse is null)
	BEGIN
		exec InUseSectionSet_NoCheck @TableName,@TableID,@UserID
		SELECT 'Edit'
	END
	else
		SELECT 'Read'
--	SELECT @InUse