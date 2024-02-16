
--[dbo].[PrecheckGetClientConfig] 7519,  '<ConfigKeys><ConfigKey>DrugTestClientEmailList</ConfigKey><ConfigKey>DrugTestSendToClientEmailList</ConfigKey></ConfigKeys>', 'dhe'
--Modified by dhe on 10/24/2023: ME: 113752 - HC- 7519 -HCA - Adjust the Configuration Key for Drug Test Expiration Link
CREATE proc [dbo].[PrecheckGetClientConfig] --2135,  '<ConfigKeys><ConfigKey>ApprovedEmplPassThroughCharges</ConfigKey><ConfigKey>NoEmplPassThroughCharges</ConfigKey><ConfigKey>NoTest</ConfigKey></ConfigKeys>'
 @clno int,
 @ClientConfigKeys varchar(2000),
 @user varchar(30) = null
 as
declare @ErrorCode int;
declare @keys int;
declare @xml XML;
declare @count int;
declare @count1 int;
declare @isemail bit;
declare @email varchar(100);
declare @parentId int;
declare @facilityId int;
declare @isParentCalendarDay varchar(10);
declare @isFacilityCalendarDay varchar(10);


SET @xml = Cast(@ClientConfigKeys as XML);


IF (
     CHARINDEX(' ',LTRIM(RTRIM(@user))) = 0 
AND  LEFT(LTRIM(@user),1) <> '@' 
AND  RIGHT(RTRIM(@user),1) <> '.' 
AND  CHARINDEX('.',@user ,CHARINDEX('@',@user)) - CHARINDEX('@',@user ) > 1 
AND  LEN(LTRIM(RTRIM(@user ))) - LEN(REPLACE(LTRIM(RTRIM(@user)),'@','')) = 1 
AND  CHARINDEX('.',REVERSE(LTRIM(RTRIM(@user)))) >= 3 
AND  (CHARINDEX('.@',@user ) = 0 AND CHARINDEX('..',@user ) = 0)
)
   SET @isemail = 1;
ELSE
   SET @isemail = 0;



Begin Transaction
Set @ErrorCode=@@Error

Create table #tblTemp
(
	ConfigurationKey varchar(50),
	Value varchar(1000)
)

if(@isemail = 0 and len(@user) > 0 )
begin
 Select top 1 @email = email from ClientContacts where username=@user and clno=@clno
end

insert into #tblTemp
Select ConfigurationKey, Value From ClientConfiguration where
clno = @clno and ConfigurationKey in (
SELECT 
 ClientConfigKey.Keys.value('.', 'varchar(50)') as ConfigKey
FROM
  @xml.nodes('/ConfigKeys/ConfigKey') as ClientConfigKey(Keys)
  )

select @count = count(*) from #tblTemp where ConfigurationKey = 'DrugTestClientEmailList'

select @count1 = count(*) from #tblTemp where ConfigurationKey = 'DrugTestSendToClientEmailList'

if(@count > 0 and @isemail = 1 and @count1 < 0)
begin
update #tblTemp set Value = isnull(Value,'') + ';' + isnull(@user,'') where ConfigurationKey = 'DrugTestClientEmailList'
end

if(@count > 0 and @isemail = 0 and @count1 < 0)
begin
update #tblTemp set Value = isnull(Value,'') + ';' + isnull(@email,'')  where ConfigurationKey = 'DrugTestClientEmailList'
end

if(@count > 0)
	begin
		if(@count1 > 0)
		--	begin
		--	insert  into #tblTemp Select top 1 'DrugTestSendToClientEmailList' as ConfigurationKey, 'True' 
		--	end
		--else
		    update #tblTemp set Value = 'True' where ConfigurationKey = 'DrugTestSendToClientEmailList'
	 end

 IF (@count = 0)
 begin

  if(@isemail = 0)
	  begin
		  insert  into #tblTemp 
		  Select top 1 'DrugTestClientEmailList' as ConfigurationKey, @email as Value 
	  end
  else
	  begin
			insert  into #tblTemp Select 'DrugTestClientEmailList' as ConfigurationKey, @user as Value
      end

  if(@count1 = 0)
	  begin
		  insert  into #tblTemp Select 'DrugTestSendToClientEmailList' as ConfigurationKey, 'False' as Value
      end
  --else
  --    update #tblTemp set Value = 'False' where ConfigurationKey = 'DrugTestSendToClientEmailList'

end

--UseCalendarDaysForDrugTestExpiration

Select @isFacilityCalendarDay = value From ClientConfiguration where clno = @clno and ConfigurationKey = 'UseCalendarDaysForDrugTestExpiration'

select @parentid = parentId from vwClient where clientid = @clno

if(@parentId > 0)
begin
Select @isParentCalendarDay = value From ClientConfiguration where clno = @parentId and ConfigurationKey = 'UseCalendarDaysForDrugTestExpiration'
end


update #tblTemp set Value = case when lower(@isParentCalendarDay) = 'true' or lower(@isFacilityCalendarDay) = 'true' then 'True'
else 'False' end where ConfigurationKey = 'UseCalendarDaysForDrugTestExpiration'


 Select * from #tblTemp

 drop table #tblTemp

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
 Commit Transaction
