
CREATE PROCEDURE [dbo].[Win_ServiceMedicaid] @apno int AS
Declare @getclientno char
Declare @getmedicaidcount int
Select @getclientno = (select client.[Medicaid/Medicare] from client
inner join appl on client.clno = appl.clno where appl.apno = @apno )
if (@getclientno = '1')
  Begin
--   update Appl set inuse = 'Merlin' where apno = @appno
   if ((select count(*) from medinteg where apno = @apno) = 0)
     INSERT INTO Medinteg (apno,sectstat,CreatedDate) VALUES (@apno,'0',getdate())
  end
--Set Inuse to Completed
Update Appl
set Inuse = 'Medic_E'
where apno = @apno
