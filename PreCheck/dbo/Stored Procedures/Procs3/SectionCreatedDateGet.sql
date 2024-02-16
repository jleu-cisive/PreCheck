CREATE PROCEDURE SectionCreatedDateGet @TableName varchar(50), @TableID int AS


if @TableName = 'Appl'
	SELECT CreatedDate FROM Appl WHERE APNO=@TableID
else if @TableName = 'Empl'
	SELECT CreatedDate FROM Empl WHERE EmplID=@TableID
else if @TableName = 'Educat'
	SELECT CreatedDate FROM Educat WHERE EducatID=@TableID
else if @TableName = 'ProfLic'
	SELECT CreatedDate FROM ProfLic WHERE ProfLicID=@TableID
else if @TableName = 'PersRef'
	SELECT CreatedDate FROM PersRef WHERE PersRefID=@TableID
else if @TableName = 'Crim'
	SELECT CreatedDate FROM Cim WHERE CrimID=@TableID   -- required change to Crim table InUse bit --> InUse varchar(8)
else if @TableName = 'Civil'
	SELECT CreatedDate FROM Civil WHERE CivilID=@TableID
else if @TableName = 'MedInteg'
	SELECT CreatedDate FROM MedInteg WHERE APNO=@TableID  --should have its own ID
else if @TableName = 'DL'
	SELECT CreatedDate FROM DL WHERE APNO=@TableID  --should have its own ID
else if @TableName='Credit' --  & Social
	SELECT CreatedDate FROM Credit WHERE APNO=@TableID  --should have its own ID
--else-
  --bad TableName