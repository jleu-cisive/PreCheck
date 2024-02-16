CREATE Proc dbo.GetNextApnoBackup
@userid  varchar(8)
as
Declare @Apno  int

SELECT Top 1  @Apno=Apno FROM Appl A 
JOIN Client C ON A.Clno = C.Clno  WHERE ( (C.Investigator1 = @userid)
  Or (C.Investigator2 = @userid))  and
A.Investigator is null and A.InUse is null and A.ApStatus != 'F' and A.Rush = 1 order by Apno asc;

if (@Apno is null)

SELECT Top 1  @Apno=Apno FROM Appl A 
JOIN Client C ON A.Clno = C.Clno   WHERE( (C.Investigator1 = @userid)
  Or (C.Investigator2 = @userid) ) and
A.Investigator is null and A.InUse is null and A.ApStatus != 'F' order by Apno asc;

if (@Apno is null)

select Top 1@Apno= Apno from  Appl A 
JOIN Client C ON A.Clno = C.Clno  where ( (C.Investigator1 is null)
  and (C.Investigator2  is null )) and A.Investigator is null and InUse is null and  ApStatus != 'F' and Rush = 1 order by Apno asc;

if (@Apno is null)

select Top 1@Apno= Apno from Appl A 
JOIN Client C ON A.Clno = C.Clno  where ( (C.Investigator1 is null)
  and (C.Investigator2  is null )) and  Investigator is null and InUse is null and  ApStatus != 'F' order by Apno asc;


if (@Apno is not null)
Select @Apno
else
Select 0;

if (@Apno is not null)

update appl set investigator = @userid where apno=@Apno;