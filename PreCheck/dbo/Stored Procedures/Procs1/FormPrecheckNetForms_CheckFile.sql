
CREATE Proc dbo.FormPrecheckNetForms_CheckFile
@nameOffile varchar(200)

As
select FormID,NameOnWeb,NameOfFile
  from dbo.PrecheckNetForms
 where NameOfFile=@nameOffile
     
