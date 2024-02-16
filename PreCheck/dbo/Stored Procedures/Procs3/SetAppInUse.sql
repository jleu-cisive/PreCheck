


create PROCEDURE [dbo].[SetAppInUse]
(@Apno int)
AS
update Appl set InUse = 'CrimVnd'
WHERE apno = @Apno and (len(InUse) = 0 or InUse is null)


