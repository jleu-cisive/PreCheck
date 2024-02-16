--====================================================================================================================== 
--Author:        Lalit Kumar
--Create Date:   12-January-2023
--Description:   insert logging information in [ThirdpartyVendorsEmEd] table per lead for employment and education  
--======================================================================================================================

CREATE PROCEDURE [dbo].[updatethirdpartyvenodorEmEd]
@sectionkeyid int = 0,
@vendorid int=0,
@sectionid int=0,
@enteredby varchar(50)=null,
@enteredvia varchar(50)=null,
@updatelastentered int=0

AS

begin
set NOCOUNT ON
	declare @apno int=0;
	declare @ThirdpartyVendorsEmEdid int=0;
	declare @numofentries int=0;
	declare @currentvendorid int=0
	declare @skip int=0;

    select top 1 @currentvendorid=ThirdPartyVendorId from  ThirdpartyVendorsEmEd WITH(NOLOCK) where SectionKeyId=@sectionkeyid and SectionId= @sectionid and isactive=1 order by ThirdpartyVendorsEmEdid desc		 
	
	if((@currentvendorid in (@vendorid))OR (isnull(@vendorid,0) IN (0)))
	begin
		set @skip=1
	end

	if(@skip not in (1))
	begin
		if(@updatelastentered in (1))
			begin
				select @numofentries=count(ThirdpartyVendorsEmEdid) from  ThirdpartyVendorsEmEd WITH(NOLOCK) where SectionKeyId=@sectionkeyid and SectionId= @sectionid
			end

		if(isnull(@numofentries,0)>0)
		begin 
				select top 1 @ThirdpartyVendorsEmEdid=ThirdpartyVendorsEmEdid from  ThirdpartyVendorsEmEd WITH(NOLOCK) where SectionKeyId=@sectionkeyid and SectionId= @sectionid order by ThirdpartyVendorsEmEdid desc
				update tpve
				set tpve.ThirdPartyVendorId=@vendorid,
				tpve.ModifyDate=getdate(),
				tpve.EnteredBy=@enteredby		
				from ThirdpartyVendorsEmEd tpve WITH(NOLOCK) where tpve.ThirdpartyVendorsEmEdid=@ThirdpartyVendorsEmEdid
		end
		else
		begin
			if(@sectionid in (1))
				begin		
					select top 1 @apno=Apno from empl WITH(NOLOCK) where EmplID=@sectionkeyid;	
					insert into ThirdpartyVendorsEmEd([ThirdPartyVendorId],[SectionKeyId],[Apno],[SectionId],[EnteredBy],[EnteredVia])
					values(@vendorid,@sectionkeyid,@apno,@sectionid,@enteredby,@enteredvia)
				end
			if(@sectionid in (2))
				begin	
					select top 1 @apno=Apno from Educat WITH(NOLOCK) where EducatID=@sectionkeyid;
					insert into ThirdpartyVendorsEmEd([ThirdPartyVendorId],[SectionKeyId],[Apno],[SectionId],[EnteredBy],[EnteredVia])
					values(@vendorid,@sectionkeyid,@apno,@sectionid,@enteredby,@enteredvia)
				end
		end
	end
set NOCOUNT OFF
end
