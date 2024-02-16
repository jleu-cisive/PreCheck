

/*--Created on 01-06-2006 get new report 
--[PrecheckDrugScreenClientSpecType] 7519,11340, '10207'
--[PrecheckDrugScreenClientSpecType] 2135,0, '0'  --1050
--[PrecheckDrugScreenClientSpecType] 1050,0, null  
--[PrecheckDrugScreenClientSpecType] 15934,0, null  
 Modified by: James Norton
 Modified date: 7/13/2021 
*/
CREATE PROCEDURE  [dbo].[PrecheckDrugScreenClientSpecType] --14080, '07519'
@clno int,
@facilitynum varchar(20) = null,
@ParentEmployerID Int = null
As
Declare @ErrorCode int,@CostCenterName varchar(100),@ParentClnoDerived int

DECLARE @ClientInfo TABLE (ClientConfiguration_DrugScreeningID int, 
[SpecType] varchar(50), 
Name varchar(100), 
FacilityName varchar(100),
DescriptiveName varchar(100)
)


  
    Select @ParentClnoDerived = ParentEmployerID
	From [HEVN].[dbo].[Facility]
	Where (FacilityCLNO = @clno and @clno <> 0) 

	if (@ParentClnoDerived is null or @ParentClnoDerived = '') 
	begin
	Select @ParentClnoDerived = ParentEmployerID
	From [HEVN].[dbo].[Facility]
	Where (FacilityCLNO = @ParentEmployerID and @ParentEmployerID <> 0) 
	END
    
	if (@ParentClnoDerived is null or @ParentClnoDerived = '') 
	begin
		Select @ParentClnoDerived = webOrderParentCLNO
		From [dbo].Client
		Where (CLNO = @clno ) 
	END
	




if(ltrim(rtrim(@facilitynum)) = '' or ltrim(rtrim(@facilitynum)) = '0' OR @facilitynum IS null or ltrim(rtrim(@facilitynum)) = 'null')

begin

Insert into @ClientInfo(
ClientConfiguration_DrugScreeningID, 
[SpecType], 
Name, 
FacilityName,
DescriptiveName
)
SELECT cc.[ClientConfiguration_DrugScreeningID],cc.[SpecType], c.Name, c.Name as FacilityName, c.DescriptiveName
  FROM [dbo].[ClientConfiguration_DrugScreening] cc
  JOIN [dbo].[Client] c  ON cc.clno=c.clno
  LEFT OUTER JOIN [dbo].[ClientPackages] cp  ON cp.clno=c.clno and cp.PackageID = cc.PackageID
  LEFT OUTER JOIN  dbo.PackageMain p ON   cp.PackageID = p.PackageID  AND p.refPackageTypeID=4
  WHERE cc.CLNO = @clno
  
IF @@RowCount = 0
begin 
Insert into @ClientInfo(
ClientConfiguration_DrugScreeningID, 
[SpecType], 
Name, 
FacilityName,
DescriptiveName
)
SELECT cc.[ClientConfiguration_DrugScreeningID],cc.[SpecType], c.Name, c.Name as FacilityName, c.DescriptiveName
  FROM [dbo].[ClientConfiguration_DrugScreening] cc
  JOIN [dbo].[Client] c   ON cc.clno=c.clno
  LEFT OUTER JOIN [dbo].[ClientPackages] cp  ON cp.clno=c.clno and cp.PackageID = cc.PackageID
  LEFT OUTER JOIN  dbo.PackageMain p ON   cp.PackageID = p.PackageID  AND p.refPackageTypeID=4
  WHERE cc.CLNO = @ParentEmployerID

  IF @@RowCount = 0
begin 
Insert into @ClientInfo(
ClientConfiguration_DrugScreeningID, 
[SpecType], 
Name, 
FacilityName,
DescriptiveName
)
SELECT cc.[ClientConfiguration_DrugScreeningID],cc.[SpecType], c.Name, c.Name as FacilityName, c.DescriptiveName
  FROM [dbo].[ClientConfiguration_DrugScreening] cc
  JOIN [dbo].[Client] c   ON cc.clno=c.clno
  LEFT OUTER JOIN [dbo].[ClientPackages] cp  ON cp.clno=c.clno and cp.PackageID = cc.PackageID
  LEFT OUTER JOIN  dbo.PackageMain p ON   cp.PackageID = p.PackageID  AND p.refPackageTypeID=4
  WHERE cc.CLNO = @ParentClnoDerived
end
end
 end

else
	BEGIN
    
		Select @CostCenterName = FacilityName 
		From [HEVN].[dbo].[Facility]
		Where FacilityCLNO = @clno and FacilityNum=@facilitynum


		if (@CostCenterName is null or @CostCenterName = '') 
		begin
		Select @CostCenterName = FacilityName 
		From [HEVN].[dbo].[Facility]
		Where ParentEmployerID = @ParentEmployerID and FacilityNum=@facilitynum
		end

		if (@CostCenterName is null or @CostCenterName = '') 

		begin
		Select @CostCenterName = FacilityName 
		From [HEVN].[dbo].[Facility]
		Where ParentEmployerID = @ParentClnoDerived and FacilityNum=@facilitynum
		END
        
		Insert into @ClientInfo(
		ClientConfiguration_DrugScreeningID, 
		[SpecType], 
		Name, 
		FacilityName,
		DescriptiveName
		)
		SELECT top 1 cc.[ClientConfiguration_DrugScreeningID],cc.[SpecType], c.Name, isnull(@CostCenterName,c.Name) FacilityName, c.DescriptiveName
		FROM [dbo].[ClientConfiguration_DrugScreening] cc
		JOIN [dbo].[Client] c ON cc.clno=c.clno
		LEFT OUTER JOIN [dbo].[ClientPackages] cp  ON cp.clno=c.clno and cp.PackageID = cc.PackageID
		LEFT OUTER JOIN  dbo.PackageMain p ON   cp.PackageID = p.PackageID  AND p.refPackageTypeID=4
		WHERE (cc.CLNO = @clno) 
		IF @@RowCount = 0
		begin
		   	Insert into @ClientInfo(
			ClientConfiguration_DrugScreeningID, 
			[SpecType], 
			Name, 
			FacilityName,
			DescriptiveName
			)
			SELECT cc.[ClientConfiguration_DrugScreeningID],cc.[SpecType], c.Name, isnull(@CostCenterName,c.Name) FacilityName, c.DescriptiveName
			FROM [dbo].[ClientConfiguration_DrugScreening] cc
			JOIN [dbo].[Client] c ON cc.clno=c.clno
	  	    LEFT OUTER JOIN [dbo].[ClientPackages] cp  ON cp.clno=c.clno and cp.PackageID = cc.PackageID
			LEFT OUTER JOIN  dbo.PackageMain p ON   cp.PackageID = p.PackageID  AND p.refPackageTypeID=4
			WHERE (cc.CLNO = @ParentEmployerID) 
			IF @@RowCount = 0
			begin
			Insert into @ClientInfo(
			ClientConfiguration_DrugScreeningID, 
			[SpecType], 
			Name, 
			FacilityName,
			DescriptiveName
			)
			SELECT cc.[ClientConfiguration_DrugScreeningID],cc.[SpecType], c.Name, isnull(@CostCenterName,c.Name) FacilityName, c.DescriptiveName
			FROM [dbo].[ClientConfiguration_DrugScreening] cc
			JOIN [dbo].[Client] c ON cc.clno=c.clno
			LEFT OUTER JOIN [dbo].[ClientPackages] cp  ON cp.clno=c.clno and cp.PackageID = cc.PackageID
			LEFT OUTER JOIN  dbo.PackageMain p ON   cp.PackageID = p.PackageID  AND p.refPackageTypeID=4
			WHERE (cc.CLNO = @ParentClnoDerived) 
			end
		end
	end

	
  

  select * from @ClientInfo
  



  


