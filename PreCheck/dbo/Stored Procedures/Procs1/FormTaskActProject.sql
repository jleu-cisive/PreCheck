
CREATE PROCEDURE [dbo].[FormTaskActProject] AS
select count(*) as cnt 
from task 
where ((statusid>=7 and statusid<14) and indentlevel=0)
