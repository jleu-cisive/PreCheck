

-- =============================================
-- Author:		James Norton
-- Create date: 7/14/2022
-- Description:	Inserts a new record into the dbo.ProfLic table 
-- =============================================

CREATE PROCEDURE  [dbo].[AddProfLic]
  @Apno int,
  @Lic_type varchar(100),
  @LicenseTypeID int,
  @Lic_No varchar(20), 
  @Expire datetime , 
  @Priv_Notes varchar(30),
  @State varchar(8),
  @Year varchar(10)
as
  BEGIN 
  set nocount on
  DECLARE @ProfLicID int;
  
  SET @ProfLicID = 10;

 
  INSERT INTO [dbo].[ProfLic]
           ([Apno]
           ,[SectStat]
           ,[Lic_Type]
		   ,[LicenseTypeID]
           ,[Lic_No]
		   ,[Year]
           ,[Expire]
           ,[State]
           ,[Priv_Notes]
           ,[IsOnReport]
           ,[IsHidden]
		 )
     VALUES (@Apno
           ,'9'
           ,@Lic_Type
		   ,@LicenseTypeID
           ,@Lic_No
		   ,@Year
           ,@Expire
		   ,@State
           ,@Priv_Notes
           ,1
           ,0
		)

  set @ProflicID = Cast(SCOPE_IDENTITY() as Int)  ;
  select @ProfLicID as 'PROFLICID'
  return @ProfLicID

  END


