CREATE FUNCTION dbo.SectionCreatedDateGet2 (@TableName varchar(50), @TableID int)
RETURNS datetime AS  
BEGIN 

DECLARE @CreatedDate datetime

if @TableName = 'Appl'
	SELECT @CreatedDate=CreatedDate FROM Appl WHERE APNO=@TableID
else if @TableName = 'Empl'
	SELECT @CreatedDate=CreatedDate FROM Empl WHERE EmplID=@TableID
else if @TableName = 'Educat'
	SELECT @CreatedDate=CreatedDate FROM Educat WHERE EducatID=@TableID
else if @TableName = 'ProfLic'
	SELECT @CreatedDate=CreatedDate FROM ProfLic WHERE ProfLicID=@TableID
else if @TableName = 'PersRef'
	SELECT @CreatedDate=CreatedDate FROM PersRef WHERE PersRefID=@TableID
else if @TableName = 'Crim'
	SELECT @CreatedDate=CreatedDate FROM Cim WHERE CrimID=@TableID   -- required change to Crim table InUse bit --> InUse varchar(8)
else if @TableName = 'Civil'
	SELECT @CreatedDate=CreatedDate FROM Civil WHERE CivilID=@TableID
else if @TableName = 'MedInteg'
	SELECT @CreatedDate=CreatedDate FROM MedInteg WHERE APNO=@TableID  --should have its own ID
else if @TableName = 'DL'
	SELECT @CreatedDate=CreatedDate FROM DL WHERE APNO=@TableID  --should have its own ID
else if @TableName='Credit' --  & Social
	SELECT @CreatedDate=CreatedDate FROM Credit WHERE APNO=@TableID  --should have its own ID
--else-
  --bad TableName

 return(@CreatedDate)



END
