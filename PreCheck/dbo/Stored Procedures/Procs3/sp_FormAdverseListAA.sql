
Create Proc dbo.sp_FormAdverseListAA

As
Declare @ErrorCode int

select AdverseActionID as Aaid,Apno
from AdverseAction
where  StatusId=16

