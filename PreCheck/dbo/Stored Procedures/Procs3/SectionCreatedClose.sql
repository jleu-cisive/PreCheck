

-- Handles usage logging for a section that was just created
-- The program that creates the section should save it with InUse set to the UserID of the person that created it
--  This routine will insert the record in the usage log 
--8/11/2005 RSK

CREATE PROCEDURE [dbo].[SectionCreatedClose]
@UserID varchar(8),
@TableName varchar(25), 
@TableID int,
@Role varchar(50)
AS

DECLARE @APNO int
DECLARE @InUse varchar(8) -- check against UserID
DECLARE @OpenTime datetime

SET @OpenTime = dbo.SectionCreatedDateGet2(@TableName, Convert(int, @TableID))

SET @APNO = dbo.GetAPNOFromTable(@TableName, Convert(int, @TableID))
--SET @APNO='12345'

INSERT INTO SectionUsage (TableName,TableID,APNO, UserID,TimeOpen,TimeClose, Role) VALUES (@TableName, Convert(int, @TableID), @APNO, @UserID,@OpenTime, GetDate(), @Role)

--Mark as not used
exec InUseSectionClear @TableName, @TableID

