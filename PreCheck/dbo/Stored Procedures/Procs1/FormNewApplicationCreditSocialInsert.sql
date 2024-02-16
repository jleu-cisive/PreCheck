CREATE PROCEDURE dbo.FormNewApplicationCreditSocialInsert
(
@APNO  int,
@Vendor  char(1),
@RepType  char(1),
@Qued  bit,
@Pulled  bit,
@SectStat  char(1),
@Report  text,
@Last_Updated  datetime,
@InUse  varchar(8),
@CreatedDate  datetime
)

AS

SET NOCOUNT OFF;

INSERT INTO dbo.Credit
    (APNO, Vendor, RepType, Qued, Pulled, SectStat,  Report, Last_Updated, InUse, CreatedDate)
VALUES
    (@APNO, @Vendor, @RepType, @Qued, @Pulled, @SectStat,  @Report, @Last_Updated, @InUse, @CreatedDate);
 
SELECT  APNO, Vendor, RepType, Qued, Pulled, SectStat, Report, Last_Updated, InUse, CreatedDate
   FROM dbo.Credit