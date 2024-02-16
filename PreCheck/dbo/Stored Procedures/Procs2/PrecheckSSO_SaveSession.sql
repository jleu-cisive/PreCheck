-- =============================================  

-- Author:  Douglas DeGenaro  

-- Create date: 12/31/2012  

-- Description: Insert an entry into the SSO table, updates the sessionId if we have expired  

-- =============================================  



-- =============================================  

-- Author:  Douglas DeGenaro  

-- Updated date: 04/25/2012  

-- Description: Added an IsSuperUser parameter, to save in the db for that user 

-- =============================================  





  

--===========================================================================================  

--Examples   

-- dbo.PrecheckSSO_SaveSession @CLNO = 2135,@UserName = 'precheck\ddegenaro',@Product = 'All',@ExpiresInDays=30,@IsSuperUser = 1  

CREATE PROCEDURE [dbo].[PrecheckSSO_SaveSession]   

 -- Add the parameters for the stored procedure here  

 @CLNO int,   

 @UserName varchar(50),  

 @Product varchar(50),  

 @ExpiresInDays int = -1,  

 @ForceReset bit = 1,

 @IsSuperUser bit = 0  

AS  

  

DECLARE @RowId int  

DECLARE @SessionId uniqueidentifier  

DECLARE @DateEntered DateTime  

DECLARE @CurrentDate DateTime  

DECLARE @DaysUp int = 0  

  

BEGIN  

 -- SET NOCOUNT ON added to prevent extra result sets from  

 -- interfering with SELECT statements.  

 SET NOCOUNT ON;  

  

/*   

 SET @RowId = 0  

 --SET @CurrentDate = '04/12/2013'  

  Set @CurrentDate = (SELECT CURRENT_TIMESTAMP)  

 -- First check to see if we already have a Token created  

 SELECT   

  @SessionID = Token,   

  @RowId = Id,  

  @DateEntered = CreatedDate  

 FROM   

  dbo.PrecheckSSO   

 WHERE   

  CLNO = @CLNO and  

  Product = @Product  

  

  --select @SessionID ,   

  --@RowId ,  

  --@DateEntered   

  

  

-- Get the original inserted date of the Entry if one, if not get current date   

 IF (@DateEntered is null)  

  SET @DateEntered = (Select @CurrentDate)  

    

  -- if no token, then create one  

  IF (@RowId = 0)    

  Begin  

  INSERT INTO [dbo].[PrecheckSSO]  

  

       (CLNO  

       ,UserName  

       ,Product  

       ,Token  

       ,ExpiresInDays  

       ,CreatedDate)             

    VALUES  

       (@CLNO  

       ,@UserName  

       ,@Product  

       ,NewID()  

       ,@ExpiresInDays  

       ,@DateEntered)  

   SET @RowId = (SELECT SCOPE_IDENTITY());         

   

 --Retrieve Token from table  

 SELECT   

  @SessionID = Token   

  FROM   

   [dbo].[PrecheckSSO] WITH (NOLOCK)   

  WHERE   

   Id = @RowId  

   

 End  

         

 --Set @CurrentDate = (SELECT CURRENT_TIMESTAMP)  

   

 -- Get the default expiration date for ExpiresInDays, if none was supplied  

   

     

  SELECT   

   @ExpiresInDays = IsNull(@ExpiresInDays,ExpiresDefault)  

  FROM   

   dbo.PrecheckSSO with (NOLOCK)   

  WHERE   

   CLNO = @CLNO and   

   Product = @Product  

    

   

   

 -- Check to see if the SSO token has expired  

 SET @DaysUp = (SELECT DATEDIFF(DD,convert(varchar,@CurrentDate,101),Convert(varchar,DateAdd(DAY,@ExpiresInDays,@DateEntered),101)))   

    -- Check to see if we succesfully received a RowId  

 --select @RowId , @DaysUp  

  

 IF (@RowId > 0)  

  BEGIN              

   ----- NOT SURE IF THE BELOW LOGIC WORKS, NEED TO TEST -----  

   IF (@DaysUp <= -1)  

    BEGIN  

     SET @SessionId = (select NewID())  

       

     

     UPDATE [dbo].[PrecheckSSO]   

     SET  

      Token = @SessionId ,  

      CreatedDate = @CurrentDate  

     WHERE Id = @RowId   

    END  

   ELSE  

    SET @SessionId = (SELECT Token from [dbo].[PrecheckSSO] where Id = @RowId)  

  END    

  SELECT @CLNO as CLNO,@UserName as UserName,@Product as Product,@SessionId as Token,@DateEntered as CreatedDate  

*/  

  

  INSERT INTO [dbo].[PrecheckSSO]  

  

       (CLNO  

       ,UserName  

       ,Product  

       ,Token  

       ,ExpiresInDays  

       ,CreatedDate

       ,IsSuperUser)             

    VALUES  

       (@CLNO  

       ,@UserName  

       ,@Product  
       ,NewID()  

       ,Case when isnull(@ExpiresInDays,0) > 0 then @ExpiresInDays else 1 end  

       ,Current_TimeStamp

       ,@IsSuperUser)  

   SET @RowId = (SELECT SCOPE_IDENTITY());   

  

  SELECT  CLNO,UserName, Product, Token, CreatedDate,cast(IsSuperUser as int) as SuperUser      

  FROM    [dbo].[PrecheckSSO]  

  WHERE   Id = @RowId      

END  
