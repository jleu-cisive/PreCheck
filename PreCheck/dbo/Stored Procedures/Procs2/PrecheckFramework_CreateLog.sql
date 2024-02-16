
CREATE procedure [dbo].[PrecheckFramework_CreateLog]  
@clno int,  
@clientapno varchar(30),  
@serviceDate datetime,  
@serviceName varchar(100),  
@Requestxml xml, 
@Responsexml xml = null, 
@apno int  
  
  
as   

if (@ResponseXml is null)
  
INSERT INTO   
 dbo.PrecheckServiceLog(clientId,clientappno,ServiceDate,ServiceName,Request,apno)   
VALUES   
 (@clno,@clientapno,@serviceDate,@serviceName,@Requestxml,@apno)
else
INSERT INTO   
 dbo.PrecheckServiceLog(clientId,clientappno,ServiceDate,ServiceName,Request,Response,apno)   
VALUES   
 (@clno,@clientapno,@serviceDate,@serviceName,@Requestxml,@ResponseXml,@apno)
