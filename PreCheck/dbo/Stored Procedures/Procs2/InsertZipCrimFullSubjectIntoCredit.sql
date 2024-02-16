CREATE PROCEDURE [dbo].[InsertZipCrimFullSubjectIntoCredit]
  @Apno int,
  @Vendor char(1),
  @RepType char(1),
  @Qued bit,
  @Pulled bit,
  @SectStat char(1),
  @Report varchar(max),
  @CreatedDate datetime,
  @IsHidden bit,
  @IsCAMReview bit
as
  set nocount on
  insert into Credit
    (Apno, Vendor, RepType, Qued, Pulled, SectStat, Report, CreatedDate, IsHidden, IsCAMReview)
  values
    (@Apno, @Vendor, @RepType, @Qued, @Pulled, @SectStat, @Report, @CreatedDate, @IsHidden, @IsCAMReview)
