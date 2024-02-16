



--[StudentCheck_GetEScreenconfig] 6774,1213,0

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StudentCheck_GetEScreenconfig] 
@CLNO int,
@programID int,	
@PackageID int
As


DECLARE @PackageDesc as varchar(100)
DECLARE @ClientProgram as varchar(100)
DECLARE @Value as varchar(10)
DECLARE @NonElectronic as varchar(10)

if @PackageID <> 0
Select @PackageDesc =  PackageDesc from PackageMain where PackageMain.PackageID =@PackageID
else 
Select @PackageDesc =  PackageDesc  FROM dbo.ClientPackages INNER JOIN  dbo.PackageMain on PackageMain.PackageID = ClientPackages.PackageID 
WHERE dbo.ClientPackages.CLNO = @CLNO and IsActive = 1

--Select *  FROM dbo.ClientPackages INNER JOIN  dbo.PackageMain on PackageMain.PackageID = ClientPackages.PackageID 
--WHERE dbo.ClientPackages.CLNO = 6774


Select @ClientProgram = ClientProgram.Name from ClientProgram where ClientProgram.ClientProgramID = @programID

			
 if ( (SELECT count(*)  FROM ClientConfiguration_DrugScreening WHERE CLNO = @CLNO) > 0)
 
 set @Value  = 'True'
else

 set @Value ='False'


set @NonElectronic = ISNULL((SELECT Value  FROM ClientConfiguration WHERE CLNO = @CLNO and ConfigurationKey = 'NonElectronic'),'False') 



if (@PackageDesc LIKE '%drug%' or @ClientProgram LIKE '%drug%')
select @PackageDesc as PackageDesc,@Value as Value,'True' as Drug,@NonElectronic as NonElectronic
else
select @PackageDesc as PackageDesc ,@Value as Value,'False' as Drug,@NonElectronic as NonElectronic






