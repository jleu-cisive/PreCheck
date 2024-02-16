CREATE  PROCEDURE InsertClientPackage
  @CLNO smallint,
  @PackageID int,
  @Rate smallmoney
as
  SET NOCOUNT ON
  INSERT INTO ClientPackages
    (CLNO, PackageID, Rate)
  VALUES
    (@CLNO, @PackageID, @Rate)
