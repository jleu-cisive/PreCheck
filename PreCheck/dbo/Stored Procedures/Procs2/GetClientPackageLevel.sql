
CREATE Proc [dbo].[GetClientPackageLevel]
@clno int
as
declare @ErrorCode int,@ParentCLNO int

Begin Transaction
Set @ErrorCode=@@Error

--check shared pricing
SELECT @PARENTCLNO = parentclno from clienthierarchybyservice
where clno = @CLNO and refhierarchyserviceid = 3;

if(@PARENTCLNO is not null)
SET @CLNO = @PARENTCLNO;

SELECT P.PackageID, P.PackageDesc, C.Rate
FROM PackageMain P, ClientPackages C
WHERE (C.CLNO = @clno)
  AND (C.PackageID = P.PackageID);


Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
