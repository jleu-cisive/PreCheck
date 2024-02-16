
--by Steve Krenek, 5/20/2003
CREATE PROCEDURE dbo.ADD_PrecheckChallenge AS

DECLARE @packageID int
INSERT INTO PackageMain Values ('PrecheckChallenge',0.00)
SELECT @packageID = @@identity

INSERT INTO PackageService VALUES (@packageID,0,99,99) --Criminal
INSERT INTO PackageService VALUES (@packageID,1,99,99) --Civil
INSERT INTO PackageService VALUES (@packageID,2,99,99) --Credit
INSERT INTO PackageService VALUES (@packageID,3,99,99) --Drivers License
INSERT INTO PackageService VALUES (@packageID,4,99,99) --Employment
INSERT INTO PackageService VALUES (@packageID,5,99,99) --Education
INSERT INTO PackageService VALUES (@packageID,6,99,99) --Professional License
INSERT INTO PackageService VALUES (@packageID,7,99,99) --Personal Reference
INSERT INTO PackageService VALUES (@packageID,8,99,99) --Social Search
