
 -- USe Precheck 
 -- Author: Nikhil Vairat 
-- Modify date:08/25/2023  
-- Description: Added functionality for I9CallbackTransform
 

CREATE  procedure [dbo].[WS_GetXsltData](@clno int,@xslt_CLNO int = null,@xslt_type varchar(100) = null)  
as  
  
if @xslt_CLNO is not null  
 if (Select  count(1)  
  From  dbo.XLATECLNO Client left join dbo.XSLFileCache XSLFile on isnull(Client.CLNO_XSLT,0) =  XSLFile.CLNO  
  Where Client.CLNOin = @xslt_CLNO and  XSLTFileData is not null) > 0  
   Set @clno = @xslt_CLNO  

if (@xslt_type = 'I9')   
 begin  
  Select  XSLTFileData,xsltnamespace  
  From  dbo.XLATECLNO Client left join dbo.XSLFileCache XSLFile on isnull(Client.CLNO_XSLT,0) =  XSLFile.CLNO  
  Where Client.CLNOin = @clno and XSLFile.XslName = 'I9CallbackTransform'  
 end  
ELSE  
 begin  
  Select  XSLTFileData,xsltnamespace  
  From  dbo.XLATECLNO Client left join dbo.XSLFileCache XSLFile on isnull(Client.CLNO_XSLT,0) =  XSLFile.CLNO  
  Where Client.CLNOin = @clno and XSLFile.XslName <> 'I9CallbackTransform'  
 end    
  
  


  
  
    
  
  