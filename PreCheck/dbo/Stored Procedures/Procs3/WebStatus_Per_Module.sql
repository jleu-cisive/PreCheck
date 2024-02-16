CREATE PROCEDURE [dbo].[WebStatus_Per_Module]
  @StartDate datetime,
  @EndDate datetime
AS
BEGIN
  
select wbs.description, EmpUsed =(SELECT count(history_status) FROM Empl E 
inner join Web_Status_History W  on E.APNO = Cast(W.history_appno as int) and 
                                    E.EmplID = Cast(W.emplid as int)
inner join websectstat ws on w.history_status = ws.code
WHERE w.history_date between @StartDate and @EndDate and ws.code <> 0 and ws.description = wbs.description
group by ws.code,ws.description),
LicUsed = (SELECT count(history_status) FROM ProfLic pl 
inner join Web_lic_History W  on PL.APNO = Cast(W.history_apno as int) and 
                                 PL.ProfLicID = Cast(W.proflicid as int)
inner join websectstat ws on w.history_status = ws.code
WHERE w.history_date between @StartDate and @EndDate and ws.code <> 0 and ws.description = wbs.description
group by ws.code,ws.description),
EduUsed = (SELECT count(history_status) FROM Educat Ed 
inner join Web_Edu_History W  on Ed.APNO = Cast(W.history_apno as int) and 
                                 Ed.EducatID = Cast(W.EducatId as int)
inner join websectstat ws on w.history_status = ws.code
WHERE w.history_date between @StartDate and @EndDate and ws.code <> 0 and ws.description = wbs.description
group by ws.code,ws.description) from websectstat wbs


END
