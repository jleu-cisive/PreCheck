
CREATE PROCEDURE [dbo].[AssignCAM] AS

--update appl set userid = (select client.cam from client where clno=appl.clno) WHERE (InUse IS NULL) AND (NeedsReview in ('R1','W1','X1','S1'))
--
--UPDATE APPL 
--SET USERID = CLIENTTB.CAM
--FROM (SELECT C.CAM, A.INUSE, A.CLNO, A.APNO FROM CLIENT C INNER JOIN APPL A ON A.CLNO=C.CLNO WHERE A.INUSE='Cams_S') CLIENTTB
--WHERE APPL.CLNO=CLIENTTB.CLNO AND APPL.INUSE='Cams_S'
Select A.apno,c.cam into #temp1
from appl (nolock) a inner join client (nolock) c on a.clno = c.clno where a.inuse = 'Cams_S' and a.userid is null

update a
set a.userid = c.cam
from appl a inner join #temp1 C on a.apno = c.apno
--client c on a.clno = c.clno where a.inuse = 'Cams_S' and a.userid is null

Update Appl
set inuse = 'Cams_E'
where inuse = 'Cams_S'

drop table #temp1