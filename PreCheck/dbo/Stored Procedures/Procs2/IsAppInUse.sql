



create  PROCEDURE [dbo].[IsAppInUse]
(@Apno int,
@InUse varchar(8) output)
AS
SELECT @InUse = 
case when len(InUse)>0 and InUse <> 'CrimVnd' then InUse
else '' end 
FROM Appl
WHERE apno = @Apno



