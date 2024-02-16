
CREATE PROCEDURE SetupClientMgmt_PackageService AS

Update PackageService SET ServiceID=ServiceType

Update PackageService SET ServiceID=9 WHERE ServiceType=0
