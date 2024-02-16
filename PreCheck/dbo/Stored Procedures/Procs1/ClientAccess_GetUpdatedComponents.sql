-- =============================================
-- Author:		Liel Alimole
-- Create date: 12/08/2013
-- Description:	Returns a id of the updated component
--Modified and Deployed by Schapyala on 04/25/2014
-- =============================================
CREATE  PROCEDURE [dbo].[ClientAccess_GetUpdatedComponents] 
@apno int,
@reopendate datetime,
@compdate datetime
as
begin


--[ClientAccess_GetUpdatedComponents]  2453517,'2014-02-26 16:15:26.170','2014-02-26 16:15:57.853'
	select ('crimLink' + convert(varchar, c.crimid)) as 'id' from crim c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate
	union
	select ('educatLink' + convert(varchar,c.educatid)) as 'id' from educat c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate
	union
	select ('proflicLink' + convert(varchar,c.proflicid)) as 'id' from proflic c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate
	union
	select ('persrefLink' + convert(varchar,c.persrefid)) as 'id' from persref c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate
	union
	select ('emplLink' + convert(varchar,c.emplid)) as 'id' from empl c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate
	union
	select ('civilLink' + convert(varchar,c.civilid)) as 'id' from civil c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate
	union
	select ('medintegLink' + convert(varchar,c.apno)) as 'id' from medinteg c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate
	union
	select ('identityLink' ) as 'id' from credit c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate and reptype='S'
	union
	select ('creditLink' ) as 'id' from credit c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate and reptype='C'
	union
	select ('mvrLink' + convert(varchar,c.apno)) as 'id' from DL c where c.apno = @apno and c.Last_Updated >= @reopendate and c.Last_Updated <= @compdate	

end
