
CREATE PROCEDURE dbo.PrecheckNetForms_Sel 

AS


select FormID,NameOnWeb,UsedFor,NameOFFile 
from PrecheckNetForms
order by NameOnWeb 


