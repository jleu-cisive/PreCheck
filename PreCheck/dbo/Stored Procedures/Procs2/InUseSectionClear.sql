CREATE PROCEDURE InUseSectionClear @TableName varchar(50), @TableID int  AS

exec InUseSectionSet_NoCheck @TableName, @TableID, null