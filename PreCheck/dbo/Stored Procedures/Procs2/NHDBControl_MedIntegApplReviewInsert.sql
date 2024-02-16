
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[NHDBControl_MedIntegApplReviewInsert]
	@APNO int, @UserName varchar(25),@Status varchar(25),@ReportText text = null,@Record text,@Mode int = 1
AS
BEGIN


SET NOCOUNT ON;
SET XACT_ABORT ON;


DECLARE @TMPCLNO int,@CLNO int;
--check hierarchy and redirect
SET @CLNO = (select clno from appl where apno = @APNO);
SET @TMPCLNO = (select parentclno from clienthierarchybyservice where clno = @clno and refhierarchyserviceid = 4);
if @TMPCLNO is not null 
BEGIN
SET @CLNO = @TMPCLNO
END

--override report text if auto-cleared
IF @ReportText is null AND @Status = 'CLEARED'
BEGIN
SET @ReportText = (SELECT case when c.medinteg_text is not null then c.medinteg_text else m.medinteg_text end as medinteg_text
	FROM   precheck_nhdb.dbo.NHDB_MedInteg_Text_Master m  left join precheck_nhdb.dbo.NHDB_MedInteg_Text_Custom c 
	on c.NHDB_MedInteg_Text_MasterID = m.NHDB_MedInteg_Text_MasterID
	and c.clno = @CLNO and c.isactive = 1 where m.medinteg_report = 'CLEARED')
END
ELSE IF @ReportText is null AND @Status = 'MATCHNOTFOUND'
BEGIN
SET @ReportText = (SELECT case when c.medinteg_text is not null then c.medinteg_text else m.medinteg_text end as medinteg_text
	FROM   precheck_nhdb.dbo.NHDB_MedInteg_Text_Master m  left join precheck_nhdb.dbo.NHDB_MedInteg_Text_Custom c 
	on c.NHDB_MedInteg_Text_MasterID = m.NHDB_MedInteg_Text_MasterID
	and c.clno = @CLNO and c.isactive = 1 where m.medinteg_report = 'MATCHNOTFOUND')
END
--resolution
IF @Mode = 1
BEGIN
BEGIN TRANSACTION
update medinteg set report = @ReportText,sectstat = 
(CASE when @Status = 'CLEARED' THEN '3'
WHEN @Status = 'POSITIVE' THEN '7'
WHEN @Status = 'POSSIBLE' THEN '7'
WHEN @Status = 'POSSIBLE CLEARED' THEN '3'

WHEN @Status = 'MATCH' THEN '7'
WHEN @Status = 'MATCHNOTFOUND' THEN '3'

ELSE '9' END),last_updated = getdate()
WHERE APNO = @APNO

--disable dual review for now 8/11/09
--update medintegapplreview set completed = 1,clearedby = @UserName
--where apno = @APNO;

insert into MedIntegLog
(APNO,Username,status,changedate)
values
(@APNO,@Username,@Status,getdate())


COMMIT TRANSACTION
END
-----------------------------------
ELSE
BEGIN	
if (select count(*) from medintegapplreview where apno = @APNO and username = @username) = 0
BEGIN
Insert into medintegapplreview
(username,apno,createddate,status,reporttext,Record)
values
(@Username,@APNO,getdate(),@Status,@ReportText,@Record)
END
END

END
