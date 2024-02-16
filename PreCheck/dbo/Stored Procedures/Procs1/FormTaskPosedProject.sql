
CREATE PROCEDURE [dbo].[FormTaskPosedProject] AS
select count(*) as cnt 
from task 
where (statusid<7  and indentlevel=0)
