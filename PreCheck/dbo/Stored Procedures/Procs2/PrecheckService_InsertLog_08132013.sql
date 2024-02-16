  

-- =============================================  

-- Author:  Doug DeGenaro  

-- Create date: January 3,2011  

-- Description:   

-- =============================================  

CREATE PROCEDURE [dbo].[PrecheckService_InsertLog_08132013]   

 -- Add the parameters for the stored procedure here  

 @clno int,   

 @clientappno Varchar(50) = null,  

 @servicedate DateTime,  

 @servicename Varchar(50),  

 @request Xml,

 @apno int = null

   

AS  

BEGIN  

 -- SET NOCOUNT ON added to prevent extra result sets from  

 -- interfering with SELECT statements.   

  

    -- Insert statements for procedure here  

 if (@apno is not null)

    insert into dbo.PrecheckServiceLog(clientid,apno,servicedate,servicename,request) values (@clno,@apno,@servicedate,@servicename,@request)  

 else

	insert into dbo.PrecheckServiceLog(clientid,clientappno,servicedate,servicename,request) values (@clno,@clientappno,@servicedate,@servicename,@request)  

END  

  


