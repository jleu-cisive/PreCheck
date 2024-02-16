

CREATE PROCEDURE dbo.ReportAdverseByClient 
@Clno int,
@StartDate datetime,
@EndDate datetime 

AS

SELECT aa.AdverseActionID,aa.APNO,aa.StatusID,r.Status CurrStatus,aa.ClientEmail,aa.Name,
       aa.Address1,aa.City,aa.State,aa.Zip,a.ApStatus,a.ApDate,a.CompDate,a.CLNO,a.SSN, 
       h.AdverseACtionHistoryID,h.AdverseChangeTypeID,h.StatusID,s.Status openStatus,
       h.UserID,h.Date AdverseDate
  FROM AdverseAction aa JOIN Appl a ON a.APNO=aa.APNO
  JOIN AdverseActionHistory h ON h.AdverseActionID=aa.AdverseActionID
  JOIN refAdverseStatus s ON s.refAdverseStatusID = h.StatusID
  join refAdverseStatus r on r.refAdverseStatusID=aa.StatusID
--Where Clno=@Clno and Status='PreAdverse Requested' and h.[Date]>=@StartDate and h.[Date]<@EndDate
Where Clno=@Clno 
  and h.StatusID=1 
  and AdverseActionHistoryID in 
                 (select min(AdverseActionHistoryID)
                    from AdverseAction a, AdverseActionHistory h 
		   where h.AdverseActionID = a.AdverseActionID
 		     and AdverseChangeTypeID=1 
 		     and date >=@StartDate and date<@EndDate
  		group by h.AdverseActionID)
order by aa.apno,h.date desc

