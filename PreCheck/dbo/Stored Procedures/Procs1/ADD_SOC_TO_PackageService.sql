CREATE PROCEDURE dbo.ADD_SOC_TO_PackageService AS

--find list of PackageID's that do not have a 'Soc' record (8)
DECLARE @Included as int
DECLARE @Max as int
DECLARE @PackageID as int
DECLARE get_next_package_id CURSOR FAST_FORWARD
 FOR 
	SELECT DISTINCT PackageID
	FROM         PackageService a
	WHERE     (NOT EXISTS
                          (SELECT     NULL
                            FROM           PackageService c
                            WHERE      (c.ServiceType = 8) AND (c.PackageID = a.PackageID)))


 OPEN get_next_package_id
 FETCH NEXT FROM get_next_package_id INTO @PackageID


--Old system Service includes 1 credit search means includes 1 social search
--Old system Service includes 2 credit searches means includes 1 social search and 1 credit search
-- so add Social & decrement Credit
WHILE @@FETCH_STATUS = 0
 BEGIN
  SELECT @Included=IncludedCount, @Max=MaxCount FROM PackageService WHERE PackageID=@PackageID and ServiceType=2
  IF @Included = 0 BEGIN
	  INSERT INTO PackageService (PackageID, ServiceType, IncludedCount, MaxCount) VALUES (@PackageID, 8, 0, @Max)
  END
  IF @Included = 1 BEGIN
	  INSERT INTO PackageService (PackageID, ServiceType, IncludedCount, MaxCount) VALUES (@PackageID, 8, 1, @Max)
	  UPDATE PackageService SET IncludedCount=0 WHERE PackageID=@PackageID and ServiceType=2
  END
  IF @Included = 2 BEGIN
	  INSERT INTO PackageService (PackageID, ServiceType, IncludedCount, MaxCount) VALUES (@PackageID, 8, 1, @Max)
	  UPDATE PackageService SET IncludedCount=1 WHERE PackageID=@PackageID and ServiceType=2
  END

  FETCH NEXT FROM get_next_package_id INTO @PackageID
 END

 CLOSE get_next_package_id
 DEALLOCATE get_next_package_id