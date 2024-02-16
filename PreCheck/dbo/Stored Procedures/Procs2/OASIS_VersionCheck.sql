-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.OASIS_VersionCheck
	@Major int,@Minor int,@Build int
AS
BEGIN
	
Declare @Result int,@MA int, @MI int,@BU int;

SET @Result = 0;

SELECT @MA = major,@MI = minor,@BU = build from versionhistory with (nolock) where application = 'OASIS';

if(	@Major < @MA or @Minor < @MI or @Build < @BU)
SET @Result = 1;
if(	@Major > @MA or @Minor > @MI or @Build > @BU)
update versionhistory set major = @Major,minor = @Minor,build = @Build,updated = getdate()
where application = 'OASIS'


SELECT @Result;

END
