CREATE Proc [dbo].[GetNextApno]
@userid  varchar(8)
as

SET NOCOUNT ON

Declare @Apno  int

--Insert  GetNextResults (testno, Apno, clno,  investigator1, Investigator2, userid, rush, timeselected)
--select 1, Apno, C.clno, C.investigator1, C.Investigator2,  @userid, 1, GetDate()  FROM Appl A 
--JOIN Client C ON A.Clno = C.Clno  WHERE ( (C.Investigator1 = @userid)
-- Or (C.Investigator2 = @userid))  and (NeedsReview = 'R2' or NeedsReview = 'X2' or NeedsReview = 'W2' or NeedsReview = 'S2') and
--A.Investigator is null and A.InUse is null and (A.ApStatus in ('P', 'W')) and A.Rush = 1 order by Apno asc

SELECT Top 1  @Apno=Apno  FROM Appl A 
JOIN Client C ON A.Clno = C.Clno  WHERE ( (C.Investigator1 = @userid)
  Or (C.Investigator2 = @userid))  and (NeedsReview = 'R2' or NeedsReview = 'X2' or NeedsReview = 'W2' or NeedsReview = 'S2') and
A.Investigator is null and A.InUse is null and (A.ApStatus in ('P', 'W')) and A.Rush = 1 order by Apno asc


/*Insert  into GetNextResults (testno, Apno, clno,  investigator1, Investigator2, userid, rush, timeselected)
values(1,  @Apno,  '', '', '', @userid, '', GetDate())*/



if (@Apno is null)

begin

/*Insert  GetNextResults (testno, Apno, clno,  investigator1, Investigator2, userid, rush, timeselected)
select 2, Apno, C.clno, C.investigator1, C.Investigator2,  @userid, 0, GetDate()  FROM Appl A 
JOIN Client C ON A.Clno = C.Clno  WHERE ( (C.Investigator1 = @userid)
 Or (C.Investigator2 = @userid))  and (NeedsReview = 'R2' or NeedsReview = 'X2' or NeedsReview = 'W2' or NeedsReview = 'S2') and
A.Investigator is null and A.InUse is null and (A.ApStatus in ('P', 'W'))  order by Apno asc
*/
SELECT Top 1  @Apno=Apno  FROM Appl A 
JOIN Client C ON A.Clno = C.Clno  WHERE ( (C.Investigator1 = @userid)
  Or (C.Investigator2 = @userid))  and (NeedsReview = 'R2' or NeedsReview = 'X2' or NeedsReview = 'W2' or NeedsReview = 'S2') and
A.Investigator is null and A.InUse is null and (A.ApStatus in ('P', 'W'))  order by Apno asc


/*Insert  into GetNextResults (testno, Apno, clno,  investigator1, Investigator2, userid, rush, timeselected)
values(2,  @Apno,  '', '', '', @userid, '', GetDate())*/

end


if (@Apno is null)
begin

/*Insert  GetNextResults (testno, Apno, clno,  investigator1, Investigator2, userid,  rush, timeselected)
select 3, Apno, C.clno, C.investigator1, C.Investigator2,  @userid, 1, GetDate()  from  Appl A 
JOIN Client C ON A.Clno = C.Clno  where ( (C.Investigator1 is null)
and (C.Investigator2  is null )) and (NeedsReview = 'R2' or NeedsReview = 'X2' or NeedsReview = 'W2' or NeedsReview = 'S2') and
A.Investigator is null and InUse is null and  (A.ApStatus in ('P', 'W')) and Rush = 1 order by Apno asc
*/
select Top 1@Apno= Apno from  Appl A 
JOIN Client C ON A.Clno = C.Clno  where ( (C.Investigator1 is null)
  and (C.Investigator2  is null )) and (NeedsReview = 'R2' or NeedsReview = 'X2' or NeedsReview = 'W2' or NeedsReview = 'S2') and
A.Investigator is null and InUse is null and  (A.ApStatus in ('P', 'W')) and Rush = 1 order by Apno asc

/*Insert  into GetNextResults (testno, Apno, clno,  investigator1, Investigator2, userid, rush, timeselected)
values(3,  @Apno,  '', '', '', @userid, '', GetDate())
*/
end


if (@Apno is null)

begin
/*
Insert  GetNextResults (testno, Apno, clno,  investigator1, Investigator2, userid,  rush, timeselected)
select 4, Apno, C.clno, C.investigator1, C.Investigator2,  @userid, 0, GetDate()  from  Appl A 
JOIN Client C ON A.Clno = C.Clno  where ( (C.Investigator1 is null)
and (C.Investigator2  is null )) and (NeedsReview = 'R2' or NeedsReview = 'X2' or NeedsReview = 'W2' or NeedsReview = 'S2') and
A.Investigator is null and InUse is null and  (A.ApStatus in ('P', 'W'))  order by Apno asc
*/
select Top 1@Apno= Apno from  Appl A 
JOIN Client C ON A.Clno = C.Clno  where ( (C.Investigator1 is null)
  and (C.Investigator2  is null )) and (NeedsReview = 'R2' or NeedsReview = 'X2' or NeedsReview = 'W2' or NeedsReview = 'S2') and
A.Investigator is null and InUse is null and  (A.ApStatus in ('P', 'W'))  order by Apno asc
/*
Insert  into GetNextResults (testno, Apno, clno,  investigator1, Investigator2, userid, rush, timeselected)
values(4,  @Apno,  '', '', '', @userid, '', GetDate())
*/
end


Select isnull(@Apno,0)


if (@Apno is not null)
begin
update appl set investigator = @userid where apno=@Apno

Insert into GetNextLogging (APNO,userid,timeselected) VALUES (@Apno,@userid,getdate())

end