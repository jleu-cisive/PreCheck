  



-- =============================================  



-- Author:  Doug DeGenaro  



-- Create date: January 3,2011  



-- Description:   



-- =============================================  



CREATE PROCEDURE [dbo].[PrecheckService_InsertLog]   



 -- Add the parameters for the stored procedure here  



 @clno int,   



 @clientappno Varchar(50) = null,  



 @servicedate DateTime,  



 @servicename Varchar(50),  



 @request Xml,



 @errorResponse Xml = null,



 @apno int = null



   



AS  



BEGIN  



 -- SET NOCOUNT ON added to prevent extra result sets from  



 -- interfering with SELECT statements.   



  



    -- Insert statements for procedure here  



 if (@apno is not null)



    insert into dbo.PrecheckServiceLog(clientid,apno,servicedate,servicename,request,Response) values (@clno,@apno,@servicedate,@servicename,@request,@errorResponse)  



 else



	insert into dbo.PrecheckServiceLog(clientid,clientappno,servicedate,servicename,request,Response) values (@clno,@clientappno,@servicedate,@servicename,@request,@errorResponse)  



END  



  




