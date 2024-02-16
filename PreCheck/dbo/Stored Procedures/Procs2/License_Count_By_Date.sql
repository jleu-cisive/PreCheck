

CREATE PROCEDURE [dbo].[License_Count_By_Date] 
	@StartDate datetime,
	@EndDate datetime
    
AS
                 select c.name as [Client Name], 
                         a.apno as [APNO],
                         a.first as [First Name],
                         a.last as [Lats Name],
                         p.lic_Type as [License Type],
                         p.state as [State],
                         p.status as [Status]
                    from proflic p 
                    join appl a 
                      on p.apno=a.apno 
                    join client c
                      on c.clno=a.clno
                    join sectstat s
                      on s.code = p.sectstat
                   where p.last_worked >= @StartDate
                     and p.last_worked < DateAdd(d,1,@EndDate)
                     and p.sectstat in ('2','3','4','5','6','7')

