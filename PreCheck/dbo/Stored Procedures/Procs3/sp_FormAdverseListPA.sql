
Create Proc dbo.sp_FormAdverseListPA

As
Declare @ErrorCode int

select AdverseActionID as Aaid,Apno
from AdverseAction
where  StatusId=1 

