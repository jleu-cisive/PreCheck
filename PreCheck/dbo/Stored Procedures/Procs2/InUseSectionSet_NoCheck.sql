CREATE PROCEDURE InUseSectionSet_NoCheck @TableName varchar(50), @TableID int, @UserID varchar(8) AS

if @TableName = 'Appl'
	UPDATE Appl SET InUse=@UserID WHERE APNO=@TableID
else if @TableName = 'Empl'
	UPDATE Empl SET InUse=@UserID WHERE EmplID=@TableID
else if @TableName = 'Educat'
	UPDATE Educat SET InUse=@UserID WHERE EducatID=@TableID
else if @TableName = 'ProfLic'
	UPDATE ProfLic SET InUse=@UserID WHERE ProfLicID=@TableID
else if @TableName = 'PersRef'
	UPDATE PersRef SET InUse=@UserID WHERE PersRefID=@TableID
else if @TableName = 'Crim'
	UPDATE Crim SET InUse=@UserID WHERE CrimID=@TableID  -- required change to Crim table InUse bit --> InUse varchar(8)
else if @TableName = 'Civil'
	UPDATE Civil SET InUse=@UserID WHERE CivilID=@TableID
else if @TableName = 'MedInteg'
	UPDATE MedInteg SET InUse=@UserID WHERE APNO=@TableID --should have its own ID
else if @TableName = 'DL'
	UPDATE DL SET InUse=@UserID WHERE APNO=@TableID --should have its own ID
else if @TableName='Credit' --  & Social
	UPDATE Credit SET InUse=@UserID WHERE APNO=@TableID --should have its own ID
--else
  --bad TableName