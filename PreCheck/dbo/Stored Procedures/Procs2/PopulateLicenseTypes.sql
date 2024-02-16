
CREATE PROCEDURE dbo.PopulateLicenseTypes

AS
BEGIN
	DECLARE @LicenseTypes varchar(1000),@ID int
	Declare @@counter int
	set @@counter=0
	
	
	Declare SourceCur cursor
	local Keyset Optimistic
	For
	Select StateBoardSourceID,Licensetypes from StateBoardSource
	Open SourceCur    /* Opening the cursor */

	fetch  Next FROM  SourceCur
	into @ID,@LicenseTypes

	while @@fetch_Status=0
	begin
	fetch next from SourceCur
	into @ID,@LicenseTypes

		Insert into StateBoardSourceLicenseType
		(SourceID,LicenseType)
		Select @ID, [value] FROM dbo.fn_Split(@LicenseTypes , ',')



set @@counter=@@counter+1
end
close SourceCur
Deallocate SourceCur

	
END
