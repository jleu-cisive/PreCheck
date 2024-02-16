CREATE PROCEDURE Iris_Bis_Ordered @crimid int  AS
declare @iriscrimcount int
declare @iriscrimcounttwo int
set @iriscrimcount = (select count(queid) from crim_que where crimid = @crimid)
set @iriscrimcounttwo = (select count(queid) from crim_que where clear = 'O' and crimid = @crimid)
If @iriscrimcounttwo = @iriscrimcount 
print (@iriscrimcount)
else
print 'No Dice'