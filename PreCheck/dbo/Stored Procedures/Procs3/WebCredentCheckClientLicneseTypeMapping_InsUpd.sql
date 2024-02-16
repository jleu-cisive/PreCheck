




--Modify: 11-29-05 Per Steve, mapping for the LicenseType as PreCheck's but lmsLicenseTypeID is null

--Modify: 11-15-05 Per Steve, not insert LicenseDescription
--Modify: hz added @MaxIndex for insert a new clientlicensetype. 4/24/06

CREATE  PROCEDURE dbo.WebCredentCheckClientLicneseTypeMapping_InsUpd

 

@EmployerID int,

@ClientLicenseTypeID int,

@LicenseType varchar(50),

--@LicenseDescription varchar(100),

@lmsLicenseTypeID int,

@lmsLicenseSubSpecialtyTypeID int,

@IsCredentiable bit,

@IsActive bit,

@IsPrimaryMapping bit,

@Flag int,          

@MaxIndex int

AS

 

declare @chkClientLicenseTypeID int -- used for modify 11-29-05

declare @chkLmsLicenseTypeID int -- used for modify 11-29-05

 

if @ClientLicenseTypeID!=0 -- update ClientLicenseType

  begin

            update dbo.ClientLicenseType

               set LicenseType=@LicenseType,

                   IsCredentiable=@IsCredentiable,

                   IsActive=@IsActive,
		   IsPrimaryMapping=@IsPrimaryMapping    

             where ClientLicenseTypeID=@ClientLicenseTypeID

  end

else -- if @ClientLicenseTypeID=0 then insert into ClientLicenseType table

  begin

    if @Flag=1 -- for LicenseType

            begin

 

                        set @chkClientLicenseTypeID=(select count(ClientLicenseTypeID) 

                                                                from ClientLicenseType 

                                                               where LicenseType=@LicenseType 

                                                                 and EmployerID=@EmployerID

                                                                 and lmsLicenseTypeID is null)

                        set @chkLmsLicenseTypeID=(select lmsLicenseTypeID 

                                                                from ClientLicenseType 

                                                               where lmsLicenseTypeID=@lmsLicenseTypeID 

                                                                 and EmployerID=@EmployerID)

                        

                        if (@chkClientLicenseTypeID>0 and @chkLmsLicenseTypeID is null) -- for updating 

                                    begin

                                                update dbo.ClientLicenseType

                                                   set LicenseType=@LicenseType

                                                       ,lmsLicenseTypeID=@lmsLicenseTypeID

                                                       ,IsCredentiable=@IsCredentiable

                                                       ,IsActive=@IsActive
						       ,IsPrimaryMapping=@IsPrimaryMapping       

                                                where ClientLicenseTypeID=(select ClientLicenseTypeID 

                                                                                         from ClientLicenseType

                                                                                        where EmployerID=@EmployerID

                                                                                          and LicenseType=@LicenseType

                                                                                          and lmsLicenseTypeID is null)

                                    end

                        else -- for inserting

                                    begin

                                                insert into dbo.ClientLicenseType(EmployerID,LicenseType,lmsLicenseTypeID,IsCredentiable,IsActive, IsPrimaryMapping,AdditionalLicenseIndex ) --4/24/06

                                                values(@EmployerID,@LicenseType,@lmsLicenseTypeID,@IsCredentiable,@IsActive,@IsPrimaryMapping, @MaxIndex); --4/24/06

                                                select ClientLicenseTypeID,EmployerID,LicenseType,IsCredentiable,IsActive, IsPrimaryMapping

                                                from dbo.ClientLicenseType

                                                where ClientLicenseTypeID=@@IDENTITY

                                    end

            end

   

     else if @Flag=0 -- for LicensetSubspecialtyType

            begin

                        insert into dbo.ClientLicenseType(EmployerID,LicenseType,lmsLicenseSubSpecialtyTypeID,IsCredentiable,IsActive, IsPrimaryMapping,AdditionalLicenseIndex)

                        values(@EmployerID,@LicenseType,@lmsLicenseSubSpecialtyTypeID,@IsCredentiable,@IsActive,@IsPrimaryMapping, @MaxIndex);

                        select ClientLicenseTypeID,EmployerID,LicenseType,IsCredentiable,IsActive,IsPrimaryMapping

                        from dbo.ClientLicenseType

                        where ClientLicenseTypeID=@@IDENTITY

            end

     else --if @Flag=2  for new LicenseType which doesn't exist in our database

            begin

                        insert into dbo.ClientLicenseType(EmployerID,LicenseType,lmsLicenseTypeID,IsCredentiable,IsActive, IsPrimaryMapping, AdditionalLicenseIndex)

                        values(@EmployerID,@LicenseType,@lmsLicenseTypeID,@IsCredentiable,@IsActive,@IsPrimaryMapping, @MaxIndex);

                        select ClientLicenseTypeID,EmployerID,LicenseType,IsCredentiable,IsActive,IsPrimaryMapping

                        from dbo.ClientLicenseType

                        where ClientLicenseTypeID=@@IDENTITY

            end 

  end


