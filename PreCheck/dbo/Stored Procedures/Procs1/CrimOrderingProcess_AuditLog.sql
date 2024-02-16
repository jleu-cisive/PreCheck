-- Alter Procedure CrimOrderingProcess_AuditLog
-- =============================================
-- Author:		Suchitra Yellapantula	
-- Create date: 2/21/2017
-- Description:	Shows User who added a criminal search to a report in a given date range (all clients)
-- EXEC dbo.[CrimOrderingProcess_AuditLog] '2020-12-01','2020-12-5'
-- Modified by Radhika Dereddy on 12/18/2020 to add A.Priv_Notes and Crim private Notes
-- Added below because while exporting the columns to excel the length of Priv_notes field is 214766 for example (APNO =5179533) 
-- and many of more so adding the max length of the excel to accommodate the export.
--	WHERE LEN(Replace(REPLACE(A.Priv_Notes , char(10),';'),char(13),';')) < 32767 
--	 AND LEN(Replace(REPLACE(TC.Priv_Notes , char(10),';'),char(13),';')) < 32767 
-- =============================================
CREATE PROCEDURE [dbo].[CrimOrderingProcess_AuditLog]
	-- Add the parameters for the stored procedure here
      @StartDate datetime,
      @EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @tempData TABLE
( 
LogID int IDENTITY(1,1),
ChangeLogID int,
TableName varchar(150),
ID int,
NewValue varchar(8000),
ChangeDate datetime,
UserID varchar(50)
)

select * 
into #temp1
from ChangeLog(nolock) where ChangeDate>@StartDate and ChangeDate<dateadd(d,1,@EndDate)
and TableName like '%crim.%' and ID<0
order by ChangeDate


select * 
into #temp_ChangeLog
from #temp1 where TableName='Crim.APNO' or TableName='Crim.CNTY_NO'
order by ChangeDate

select * 
into #temp_Crim
from Crim C 
where C.CreatedDate>@StartDate and C.CreatedDate<dateadd(d,1,@EndDate)

insert into @tempData(ChangeLogID, TableName, ID, NewValue, ChangeDate, UserID)
select TCL.HEVNMgmtChangeLogID, TCL.TableName, TCL.ID, TCL.NewValue, TCL.ChangeDate, TCL.UserID
from #temp_ChangeLog TCL

select TD.ChangeLogID, TD.NewValue [APNO],
(CASE WHEN ((select TableName from @tempData where LogID = (TD.LogID+1))='Crim.CNTY_NO'
            and (SELECT UserID from @tempData where LogID = (TD.LogID+1))=TD.UserID)
      THEN (select NewValue from @tempData where LogID = (TD.LogID+1))  
	  ELSE '' END) [CNTY_NO],
TD.ChangeDate, TD.UserID
into #temp3
from @tempData TD
where TD.TableName='Crim.APNO'

delete from #temp3 where isnull(CNTY_NO,'')=''

--select * from #temp3

select T3.APNO [Report #],MC.minCrimID,A.ApDate [Report Created Date], C.A_County [County of Crim Search], C.State [State of Crim Search], U.Name [User Who Ordered],T3.ChangeDate
into #temp_Final
from #temp3 T3
inner join Appl A on A.APNO = T3.APNO
inner join dbo.TblCounties C on C.CNTY_NO = T3.CNTY_NO
inner join Users U on U.UserID = T3.UserID
inner join 
(
  SELECT TC.APNO, TC.CNTY_NO,min(TC.CrimID) [minCrimID]
  from #temp3 T3A
  inner join Crim TC on T3A.APNO = TC.APNO and T3A.CNTY_NO = TC.CNTY_NO --and DATEDIFF(mi,T3A.ChangeDate, TC.CreatedDate)<5
  GROUP BY TC.APNO, TC.CNTY_NO
) MC on MC.APNO = T3.APNO and MC.CNTY_NO = T3.CNTY_NO --and DATEDIFF(mi, MC.CreatedDate, T3.ChangeDate)<1

--select * from #temp_Final
--select * from #temp3
--select * from #temp_Crim


delete from #temp_Crim where CrimID in (select minCrimID from #temp_Final)


(
	(select TF.[Report #], cast(TF.[Report Created Date] as date) [Report Created Date], TF.[County of Crim Search], TF.[State of Crim Search], 
	TF.[User Who Ordered], TF.ChangeDate [Date Ordered/Saved],
	Replace(REPLACE(A.Priv_Notes , char(10),';'),char(13),';') as [Application Private Notes],
	Replace(REPLACE(C.Priv_Notes , char(10),';'),char(13),';') as [Criminal Private Notes]
	from #temp_Final TF
	INNER JOIN APPL A on TF.[Report #]= A.APNO 
	INNER JOIN Crim C on A.APNO = C.APNO
	WHERE LEN(Replace(REPLACE(A.Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/11/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.
	 AND LEN(Replace(REPLACE(C.Priv_Notes , char(10),';'),char(13),';')) < 32767 
	)
UNION ALL
	(select TC.APNO [Report #],cast(A.ApDate as date) [Report Created Date], C.A_County [County of Crim Search], C.State [State of Crim Search],
	 '' [User Who Ordered], TC.CreatedDate [Date Ordered/Saved],
	Replace(REPLACE(A.Priv_Notes , char(10),';'),char(13),';') as [Application Private Notes],
	Replace(REPLACE(TC.Priv_Notes , char(10),';'),char(13),';') as [Criminal Private Notes]
	 from #temp_Crim TC
	 inner join Appl A on A.APNO = TC.APNO
	 inner join dbo.TblCounties C on C.CNTY_NO = TC.CNTY_NO
	 WHERE LEN(Replace(REPLACE(A.Priv_Notes , char(10),';'),char(13),';')) < 32767 --Added by Radhika dereddy on 06/11/2020 this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) and many of more so adding the max length of the excel to accommodate the export.
	 AND LEN(Replace(REPLACE(TC.Priv_Notes , char(10),';'),char(13),';')) < 32767 
	 )
) order by 1

drop table #temp1
drop table #temp3
drop table #temp_ChangeLog
drop table #temp_Crim
drop table #temp_Final

END
