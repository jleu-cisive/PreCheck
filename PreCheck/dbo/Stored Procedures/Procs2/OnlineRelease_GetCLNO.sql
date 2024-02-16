
  
  
--OnlineRelease_GetCLNO '00079','','7519'  
-- =============================================  
-- Author:  kiran miryala  
-- Create date: 7/19/2012  
-- Description:  This SQL is used for HCA integration wher they send us facility number and we update with there client number searching from  Facility table in HEVN  
-- =============================================  
-- =============================================  
-- Edited BY:  kiran miryala  
-- Edited date: 8/16/2012  
-- Description:  Added a nes Parameter @ReqNumber to look for Facility number   
-- =============================================  
-- =============================================  
-- modified BY:  Santosh chapyala  
-- Edited date: 01/12/2015  
-- Description:  Changed the logic to use only ReqNumber process level to derive CLNO. Not using COID anymore.
-- =============================================  
CREATE PROCEDURE [dbo].[OnlineRelease_GetCLNO]  
@COID varchar(10) = null,  
@ReqNumber varchar(20) =null,  
@ClientIdIn varchar(5) ,  
@ClientAppNo varchar(20)=null,  
@RecruiterEmail varchar(50)=null  
AS  
BEGIN  
 DECLARE @ClientIdOut varchar(5)
 DECLARE @FacilityNum varchar(20)  
 DECLARE @EmployerID_IsOneHR int

SET @ReqNumber = Replace(@ReqNumber,'INT-','')

IF @ReqNumber like 'StaRN%'  --Exception for HCA to support their StaRN program.  - schapyala on 02/24/22016
	Set @FacilityNum = null --This will ensure that the proc uses COID to deduce the FacilityCLNO
else
	Set @FacilityNum = Replace(SUBSTRING(@ReqNumber,1,CHARINDEX('-',@ReqNumber)),'-','')



IF isnull(@FacilityNum,'') <> ''   
	SELECT  @ClientIdOut =  FacilityCLNO ,@EmployerID_IsOneHR = Case when  IsOneHR = 1 then ParentEmployerID else 1234 end  
	FROM     HEVN..[Facility]  
	WHERE     (ParentEmployerID = @ClientIdIn --or Employerid = @ClientIdIn
	)  
	and (FacilityNum = @FacilityNum)  


if @ClientIdOut is null and isnull(@FacilityNum,'') = ''
BEGIN
	SELECT  @ClientIdOut =  FacilityCLNO  
	FROM         [HEVN].[dbo].[Facility]  
	WHERE     (ParentEmployerID = @ClientIdIn  --or Employerid = @ClientIdIn
	)  
	and (FacilityNum = @COID ) 

	set @FacilityNum = @COID
END 

if @ClientIdOut is null
	Set @ClientIdOut = @ClientIdIn
else
	--Added by schapyala to make sure FacilityCLNOs' are auto-configured to be submitted through webservice
	Begin
		if (Select count(1) From dbo.XlateCLNO Where CLNOin = @ClientIdOut)=0
			Insert Into dbo.XlateCLNO
			Select CLNOout,@ClientIdOut,CLNO_XSLT
			From  dbo.XlateCLNO 
			Where CLNOin = @ClientIdIn

	End
  
INSERT INTO [dbo].[Release_Log]  
           ([ClientIdIn]  
           ,[ClientAppNo]  
           ,[RecruiterEmail]  
           ,[ReqNumber]  
           ,[COID]  
           ,[ClientIdOut])  
     VALUES  
           (@ClientIdIn,  
           @ClientAppNo  
           ,@RecruiterEmail  
           ,@ReqNumber  
           ,@COID  
           ,@ClientIdOut)  
  
Select @ClientIdOut as 'EmployerID', @FacilityNum as  'FacilityNum',isnull(@EmployerID_IsOneHR,1234) EmployerID_Notify
  
END  
  
  
