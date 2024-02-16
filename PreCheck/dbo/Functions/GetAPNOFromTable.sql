CREATE FUNCTION dbo.GetAPNOFromTable (@TableName varchar(50), @TableID int) 
RETURNS int AS  
BEGIN 

DECLARE @APNO int

if @TableName = 'Appl'
	SET @APNO = @TableID
else if @TableName = 'ProfLic'
             SELECT @APNO=APNO FROM ProfLic WHERE ProfLicID=@TableID
else if @TableName = 'Empl'
	SELECT @APNO=APNO FROM Empl WHERE EmplID=@TableID
else if @TableName = 'Educat'
	SELECT @APNO=APNO FROM Educat WHERE EducatID=@TableID
else if @TableName = 'PersRef'
	SELECT @APNO=APNO FROM PersRef WHERE PersRefID=@TableID
else if @TableName = 'Crim'
	SELECT @APNO=APNO FROM Crim WHERE CrimID=@TableID  -- required change to Crim table InUse bit --> InUse varchar(8)
else if @TableName = 'Civil'
	SELECT @APNO=APNO FROM Civil WHERE CivilID=@TableID
else if @TableName = 'MedInteg'
	SELECT @APNO=APNO FROM MedInteg WHERE APNO=@TableID --should have its own ID
else if @TableName = 'DL'
	SELECT @APNO=APNO FROM DL WHERE APNO=@TableID --should have its own ID
else if @TableName='Credit' --  & Social
	SELECT @APNO=APNO FROM Credit WHERE APNO=@TableID --should have its own ID
--else
  --bad TableName

return(@APNO)



END








