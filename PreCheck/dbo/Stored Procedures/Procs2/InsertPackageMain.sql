CREATE PROCEDURE InsertPackageMain
	@PackageDesc varchar(20),
	@DefaultPrice smallmoney,
	@PackageID int OUTPUT
AS
SET NOCOUNT ON
INSERT INTO PackageMain (PackageDesc, DefaultPrice)
VALUES (@PackageDesc, @DefaultPrice)
SET @PackageID = @@IDENTITY
