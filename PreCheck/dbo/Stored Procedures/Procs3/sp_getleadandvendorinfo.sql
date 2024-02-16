--====================================================================================================================== 
--Author:        Lalit Kumar
--Create Date:   3-january-2023
--Description:   get add charges information from InvDetail_Reconciliation table, feetypebysection,feetype,iris_researchers_charges table
--- updated by Lalit on 21 feb 23 to include license tab info
--  updated by Lalit on 24 April 23 for showing additional feetypes for integrated vendors
--====================================================================================================================== 


CREATE procedure [dbo].[sp_getleadandvendorinfo]
 @apno int,
 @sectionkeyid int,
 @category int,
 @thirdpartyvendor int
as

--declare @apno int=6959892
--declare @sectionkeyid int=9731588
--declare @category int=q
--declare @thirdpartyvendor int=0

begin
SET NOCOUNT ON
--declare @ThirdpartyVendorsEmEdid int=0
--declare @apno int=6959892 
--declare @sectionkeyid int=9731588
--declare @category int=1
--declare @thirdpartyvendor int=0
	if(@category in (1))
		begin
		if(@thirdpartyvendor in (0))
		begin		
         select top 1 @thirdpartyvendor=ThirdPartyVendorId from  ThirdpartyVendorsEmEd WITH(NOLOCK) where SectionKeyId=@sectionkeyid and SectionId= 1 and isactive=1 order by ThirdpartyVendorsEmEdid desc		 
		 end
drop table if exists #tempempl
			select t1.feetypeid,t1.feetype,t1.Amount,t1.Description,t1.SurCharge,t1.ClientPassThroughFee,t1.ThirdPartyVendorId,t1.VendorName,t1.SectionId
			,t1.BillToClient,t1.IsReadonly,t2.APNO,t2.SectionKeyId,t2.FullName,t2.Employer,t2.Investigator,'' as Ver_By into #tempempl
			from(select ft.FeeTypeId,ft.Feetype,case when ft.FeeTypeId not in (1,2) then NULL else case when ft.FeeTypeId =1 then ServiceFee else ClientPassThroughFee end end as Amount
			--,tpv.ServiceFee,tpv.PassThroughFee
			,tpv.SurCharge,tpv.ClientPassThroughFee
			,tpv.ThirdPartyVendorId,tpv.VendorName,fts.BillToClient,fts.SectionId,case when ft.FeeTypeId in (1,2) then CONCAT('Employment: ',tpv.VendorName) else Null end as [Description]
			,case when tpv.IsIntegrated=1 and ft.FeeTypeId in (1,2) then 1 else 0 end as [isreadonly]
			,ROW_NUMBER()over (order by ft.feetypeid asc)as rn
			from FeeType ft left join FeeTypeBySection fts on ft.FeeTypeId=fts.FeeTypeId and ft.Isactive=1 and  fts.Isactive=1 and fts.SectionId=@category and  fts.ThirdPartyVendorId =@thirdpartyvendor--in (5069,5049)
			left join ThirdPartyVendors tpv on fts.ThirdPartyVendorId=tpv.ThirdPartyVendorId and tpv.Isactive=1 and tpv.SectionId=@category
			)t1
			full outer join
			(select a.Apno,e.EmplID as SectionKeyId,CONCAT(a.last,', ',a.First)as FullName,1 as SectionId,e.Employer,e.Investigator,e.Ver_By
			,ROW_NUMBER() over (order by a.apno)as rn
			from appl a WITH(NOLOCK) inner join empl e WITH(NOLOCK) on a.APNO=e.Apno where e.EmplID=@sectionkeyid
			)t2
			on t1.rn=t2.rn
			--order by t1.FeeTypeId
			select tmp.* from #tempempl tmp LEFT join ThirdPartyVendors tpv on tpv.ThirdPartyVendorId=tmp.thirdpartyvendorid where tmp.FeeTypeId in (1,2) OR (feetypeid=4 AND tpv.IsIntegrated=1)--INNER JOIN ThirdPartyVendors tpv on tmp.thirdpartyvendorid=tpv.ThirdPartyVendorId  where tmp.FeeTypeId in (1,2) OR (tpv.IsIntegrated=1 AND tmp.feetypeid=4)
			union all
			select ft.FeeTypeId,ft.Feetype,idrc.Amount+idrc.Surcharge as Amount,idrc.Description,idrc.Surcharge,null as ClientPassThroughFee,idrc.VendorId,tpv.VendorName as VendorName,idrc.SectionId,
			cast(case when idrc.invdetid is null then 0 else 1 end as bit) as BillToClient,1 as IsReadOnly,idrc.APNO,idrc.SectionKeyId,null as FullName,null as Employer,
			null as Investigator,cast(idrc.ModifyDate as varchar(50))as ver_by
			 from InvDetail_Reconciliation idrc WITH(NOLOCK) inner join FeeType ft on idrc.FeeTypeId=ft.FeeTypeId and idrc.Isactive=1
			inner join ThirdPartyVendors tpv WITH(NOLOCK) on idrc.VendorId=tpv.ThirdPartyVendorId 
			where idrc.SectionKeyId=@sectionkeyid and idrc.SectionId=@category AND (idrc.InvDetID IS NOT NULL OR idrc.EnteredVia='WebApp')
			drop table if exists #tempempl
end

if (@category in (5))
begin

--declare @sectionkeyid int=45367851
--declare @category int=5
 drop table if exists #tempcrim
		  select feetypeid,feetype,case when t3.Feetypeid in(1,2) then case when t3.FeeTypeId=1 then t3.VendorFee else isnull(t3.ClientPassThroughFee,0.0) end else null  end as Amount,case when t3.[FeeTypeId] in (1,2) then Description else null end as [Description] ,SurCharge,ClientPassThroughFee,ThirdPartyVendorId,VendorName,SectionId
			, BillToClient, IsReadonly,APNO,SectionKeyId,FullName,Employer,'' Investigator, '' as Ver_By into #tempcrim
				from
			(select t1.feetypeid,t1.feetype,case when t1.Feetypeid in(1,2) then case when t1.FeeTypeId=1 then t2.VendorFee else t2.ClientPassThroughFee end else null  end as Amount,first_value(t2.Description) over ( order by t1.feetypeid)as [Description],0.0 as SurCharge,first_value(t2.ClientPassThroughFee) over ( order by t1.feetypeid)ClientPassThroughFee,first_value(t2.ThirdPartyVendorid) over ( order by t1.feetypeid)ThirdPartyVendorId,first_value(t2.VendorName) over ( order by t1.feetypeid)VendorName,@category as SectionId
			,CAST(case when t1.FeeTypeId in (2,4) then 1 else 0 end as bit) as BillToClient,case when t1.FeeTypeId in (1,2) then 1 else 0 end as IsReadonly,t2.APNO,t2.SectionKeyId,t2.FullName,t2.Employer,null as Investigator,null as Ver_By,t2.VendorFee
						

			from			
			(select ROW_NUMBER() over (order by ft.feetypeid asc)as rn,* from FeeType ft where ft.Isactive=1)t1 left join 
			(select CONCAT(a.last,', ',a.First)as FullName,cast(cr.vendorid as int) as ThirdPartyVendorid,irc.Researcher_other as VendorFee,tbc.PassThroughCharge as ClientPassThroughFee,ir.R_Name as VendorName,
			cr.County as Employer,cr.CrimID as SectionKeyId,cr.APNO as APNO,0 as SurCharge,CONCAT('Criminal Search: ',tbc.A_County,', ',tbc.State,', ',tbc.Country) as [Description]			
			,ROW_NUMBER() over (order by a.apno)as rn
			from Crim cr WITH(NOLOCK) inner join Iris_Researcher_Charges irc WITH(NOLOCK)
			on cr.vendorid=irc.Researcher_id and cr.CNTY_NO=irc.cnty_no
			inner join TblCounties tbc WITH(NOLOCK) on cr.CNTY_NO=tbc.CNTY_NO
			inner join Iris_Researchers ir WITH(NOLOCK) on cr.vendorid=ir.R_id
			inner join appl a WITH(NOLOCK) on cr.APNO=a.APNO
			where cr.CrimID=@sectionkeyid)t2 on t1.rn=t2.rn)t3
			select * from #tempcrim
			union all
			select ft.FeeTypeId,ft.Feetype,idrc.Amount+idrc.Surcharge as Amount,idrc.Description,idrc.Surcharge,null as ClientPassThroughFee,idrc.VendorId,ir.R_Name as VendorName,idrc.SectionId,
			cast(case when idrc.invdetid is null then 0 else 1 end as bit) as BillToClient,1 as IsReadOnly,idrc.APNO,idrc.SectionKeyId,null as FullName,null as Employer,
			null as Investigator,cast(idrc.ModifyDate as varchar(50))as ver_by
			 from InvDetail_Reconciliation idrc WITH(NOLOCK) inner join FeeType ft on idrc.FeeTypeId=ft.FeeTypeId and idrc.Isactive=1
			inner join Iris_Researchers ir WITH(NOLOCK) on idrc.VendorId=ir.R_id 
			where SectionKeyId=@sectionkeyid and SectionId=@category AND (idrc.InvDetID IS NOT NULL OR idrc.EnteredVia='WebApp')
			 drop table if exists #tempcrim
			--select * from Iris_Researcher_Charges where Researcher_id=86420
			-- exec [sp_getleadandvendorinfo] 6887855,45367851,5,5080
end

if (@category in (6))
begin

set @thirdpartyvendor =5095
		--declare @apno int=6963823
		drop table if exists #tempdl
		select first_value(t2.ClientPassThroughFee) over ( order by t1.feetypeid)as ClientPassThroughFee2,first_value(t2.description) over ( order by t1.feetypeid)as description2,* into #tempdl from
		    (select ft.FeeTypeId,ft.Feetype,case when ft.FeeTypeId not in (1,2) then NULL else case when ft.FeeTypeId =1 then ServiceFee else ClientPassThroughFee end end as Amount
			,tpv.SurCharge,tpv.ThirdPartyVendorId,tpv.VendorName,fts.BillToClient,fts.SectionId
			,case when tpv.IsIntegrated=1 and ft.FeeTypeId in (1,2) then 1 else 0 end as [isreadonly]
			,ROW_NUMBER()over (order by ft.feetypeid asc)as rn
			from FeeType ft left join FeeTypeBySection fts on ft.FeeTypeId=fts.FeeTypeId and ft.Isactive=1 and  fts.Isactive=1 and fts.SectionId=@category and  fts.ThirdPartyVendorId =@thirdpartyvendor
			left join ThirdPartyVendors tpv on fts.ThirdPartyVendorId=tpv.ThirdPartyVendorId and tpv.Isactive=1 and tpv.SectionId=@category)t1
		 
		full outer join
		(select a.Apno,msf.PassThroughFee as ClientPassThroughFee,case when d.MVRLoggingId>0 then MVRLoggingId else d.APNO end as SectionKeyId,CONCAT(a.last,', ',a.First)as FullName,msf.StateName,a.DL_State Investigator,null Ver_By
			, CONCAT('MVR State Fee for ',a.DL_State)  as [Description]
			,ROW_NUMBER() over (order by a.apno)as rn2
		from dl d WITH(NOLOCK)
          inner join appl a WITH(NOLOCK) on d.apno = a.apno
		  left join MvrStateFees msf on a.DL_State=msf.StateCode
		  where a.apno=@apno)t2 on t1.rn=t2.rn2
		  --select * from #tempdl
		  select feetypeid,feetype,case when Feetypeid in(1,2) then case when FeeTypeId=1 then Amount else isnull(ClientPassThroughFee2,0.0) end else null  end as Amount,case when [FeeTypeId] in (1,2) then case when FeeTypeId=1 then REPLACE(Description2,'State','Service') else Description2 end else null end as [Description] ,SurCharge,ClientPassThroughFee2 as ClientPassThroughFee,ThirdPartyVendorId,VendorName,SectionId
			, BillToClient, IsReadonly,APNO,SectionKeyId,FullName,statename as Employer, Investigator, '' as Ver_By
				from  #tempdl
			union all
			select ft.FeeTypeId,ft.Feetype,idrc.Amount+idrc.Surcharge as Amount,idrc.Description,idrc.Surcharge,null as ClientPassThroughFee,idrc.VendorId,tpv.VendorName as VendorName,idrc.SectionId,
			cast(case when idrc.invdetid is null then 0 else 1 end as bit) as BillToClient,1 as IsReadOnly,idrc.APNO,idrc.SectionKeyId,null as FullName,null as Employer,
			null as Investigator,cast(idrc.ModifyDate as varchar(50))as ver_by
			 from InvDetail_Reconciliation idrc WITH(NOLOCK) inner join FeeType ft on idrc.FeeTypeId=ft.FeeTypeId and idrc.Isactive=1
			inner join ThirdPartyVendors tpv WITH(NOLOCK) on idrc.VendorId=tpv.ThirdPartyVendorId 
			where idrc.SectionKeyId=@sectionkeyid AND idrc.APNO=@apno and idrc.SectionId=@category AND (idrc.InvDetID IS NOT NULL OR idrc.EnteredVia='WebApp')
			drop table if exists #tempdl
				-- exec [sp_getleadandvendorinfo] 6954213,45367851,6,5080  ----1861153
end

if (@category in (2))
begin
--SYSTEM:Education:NCH/University of Utah
--declare @apno int=6954213
--declare @sectionkeyid int=5542051
--declare @category int=2
--declare @thirdpartyvendor int=6094
 
if(@thirdpartyvendor in (0))
begin		
    select top 1 @thirdpartyvendor=ThirdPartyVendorId from  ThirdpartyVendorsEmEd WITH(NOLOCK) where SectionKeyId=@sectionkeyid and SectionId= 2 and isactive=1 order by ThirdpartyVendorsEmEdid desc		 
	end
--if (
--	select Contact_Name
--	from Educat
--	where EducatID = @sectionkeyid)
--= 'NCH'
--begin
--set @thirdpartyvendor = 6093
--		end
--		else
--		begin
--set @thirdpartyvendor = 6094
--		end

declare @school varchar(50)=null
		drop table if exists #tempedu		

		select @school=school from Educat WITH(NOLOCK) where EducatID=@sectionkeyid
		select CONCAT('SYSTEM:Education:',t1.VendorName,'/',@school) as Description,* into #tempedu from 

		(select ft.FeeTypeId,ft.Feetype,case when ft.FeeTypeId not in (1,2) then NULL else case when ft.FeeTypeId =1 then ServiceFee+SurCharge else ClientPassThroughFee-SurCharge end end as Amount
		,tpv.SurCharge,tpv.ClientPassThroughFee,tpv.ThirdPartyVendorId,tpv.VendorName,fts.BillToClient,fts.SectionId,tpv.IsIntegrated
		,case when tpv.IsIntegrated=1 and ft.FeeTypeId in (1,2) then 1 else 0 end as [isreadonly]
		,ROW_NUMBER()over (order by ft.feetypeid asc)as rn
		from FeeType ft left join FeeTypeBySection fts on ft.FeeTypeId=fts.FeeTypeId and ft.Isactive=1 and  fts.Isactive=1 and fts.SectionId=@category and  fts.ThirdPartyVendorId =@thirdpartyvendor
		left join ThirdPartyVendors tpv on fts.ThirdPartyVendorId=tpv.ThirdPartyVendorId and tpv.Isactive=1 and tpv.SectionId=@category)t1
		full outer join
		(select a.Apno,ed.EducatID as SectionKeyId,CONCAT(a.last,', ',a.First)as FullName,ed.School as Employer,ed.Investigator Investigator,ed.Contact_Name Ver_By
			,ROW_NUMBER() over (order by a.apno)as rn2
		from Educat ed WITH(NOLOCK)
          inner join appl a WITH(NOLOCK) on ed.apno = a.apno		  
		  where ed.EducatID=@sectionkeyid)t2 on t1.rn=t2.rn2
			drop table if exists #tempedu2
		select feetypeid,feetype,case when IsIntegrated=1 then case when Feetypeid in(1,2) then case when FeeTypeId=1 then Amount else 0.0 end else null  end else null end as Amount,case when [FeeTypeId] in (1,2) and IsIntegrated=1 then Description else null end as [Description] ,SurCharge, ClientPassThroughFee,ThirdPartyVendorId,VendorName,SectionId
			, BillToClient, IsReadonly,APNO,SectionKeyId,FullName, Employer, Investigator, '' as Ver_By INTO #tempedu2
				from  #tempedu 
		select tmp.* FROM #tempedu2 tmp LEFT JOIN ThirdPartyVendors tpv ON tpv.ThirdPartyVendorId=tmp.thirdpartyvendorid where tmp.FeeTypeId in (1,2) OR (feetypeid=4 AND tpv.IsIntegrated=1)--INNER JOIN ThirdPartyVendors tpv on tmp.thirdpartyvendorid=tpv.ThirdPartyVendorId  where tmp.FeeTypeId in (1,2) OR (tpv.IsIntegrated=1 AND tmp.feetypeid=4)
		union all
			select ft.FeeTypeId,ft.Feetype,idrc.Amount+idrc.Surcharge as Amount,idrc.Description,idrc.Surcharge,null as ClientPassThroughFee,idrc.VendorId,tpv.VendorName as VendorName,idrc.SectionId,
			cast(1 as bit) as BillToClient,1 as IsReadOnly,idrc.APNO,idrc.SectionKeyId,null as FullName,null as Employer,
			null as Investigator,cast(idrc.ModifyDate as varchar(50))as ver_by
			 from InvDetail_Reconciliation idrc WITH(NOLOCK) inner join FeeType ft on idrc.FeeTypeId=ft.FeeTypeId and idrc.Isactive=1
			inner join ThirdPartyVendors tpv on idrc.VendorId=tpv.ThirdPartyVendorId 
			where idrc.SectionKeyId=@sectionkeyid and idrc.SectionId=@category AND (idrc.InvDetID IS NOT NULL OR idrc.EnteredVia='WebApp')
				drop table if exists #tempedu
				drop table if exists #tempedu2
	-- exec [sp_getleadandvendorinfo] 6954213,5542051,2,6093  ----1861153
	-- exec [sp_getleadandvendorinfo] 6963823,6963823,6,5095  ----1861153
	-- sp_getleadandvendorinfo 167187,19351,2,6093
    -- sp_getleadandvendorinfo 167187,19356,2,6154
	 -- sp_getleadandvendorinfo 167187,19361,2,0

end
--License:Board Fee/ (board name)
if (@category in (4))
begin
		--DECLARE @category int=4
  --      DECLARE @thirdpartyvendor INT =6153
		--declare @sectionkeyid int=3967420
		--drop table if exists #tempprof
		set @thirdpartyvendor =6153
			select t1.feetypeid,t1.feetype,case WHEN t1.FeeTypeId=1 THEN 0 ELSE NULL END as Amount,FIRST_VALUE(concat(t1.Description,t2.Organization))over ( order by t1.feetypeid)as [Description],t1.SurCharge,t1.ClientPassThroughFee,t1.ThirdPartyVendorId,t1.VendorName,t1.SectionId
			,t1.BillToClient,CASE WHEN t1.FeeTypeId=1 THEN 1 ELSE 0 END as IsReadOnly,t2.APNO,t2.SectionKeyId,t2.FullName,t2.Organization as Employer,t2.Investigator,'' as Ver_By into #tempprof
			from(
			--DECLARE @category int=4
			-- DECLARE @thirdpartyvendor INT =6153
			select ft.FeeTypeId,ft.Feetype,case when ft.FeeTypeId not in (1,2) then NULL else case when ft.FeeTypeId =1 then ServiceFee else ClientPassThroughFee end end as Amount
			--,tpv.ServiceFee,tpv.PassThroughFee
			,tpv.SurCharge,tpv.ClientPassThroughFee
			,tpv.ThirdPartyVendorId,tpv.VendorName,fts.BillToClient,fts.SectionId,case when ft.FeeTypeId in (1,2) then 'License:Board Fee | ' else Null end as [Description]
			,case when tpv.IsIntegrated=1 and ft.FeeTypeId in (1,2) then 1 else 0 end as [isreadonly]
			,ROW_NUMBER()over (order by ft.feetypeid asc)as rn
			from FeeType ft left join FeeTypeBySection fts on ft.FeeTypeId=fts.FeeTypeId and ft.Isactive=1 and  fts.Isactive=1 and fts.SectionId=@category and  fts.ThirdPartyVendorId =@thirdpartyvendor--in (5069,5049)
			left join ThirdPartyVendors tpv on fts.ThirdPartyVendorId=tpv.ThirdPartyVendorId and tpv.Isactive=1 and tpv.SectionId=@category
			)t1
			full outer join
			(select a.Apno,p.ProfLicID as SectionKeyId,CONCAT(a.last,', ',a.First)as FullName,4 as SectionId,p.Organization,p.Investigator,p.[State]
			,ROW_NUMBER() over (order by a.apno)as rn
			from appl a WITH(NOLOCK) inner join ProfLic p WITH(NOLOCK) on a.APNO=p.Apno where p.ProfLicID=@sectionkeyid
			)t2
			on t1.rn=t2.rn
			--order by t1.FeeTypeId
			select tmp.* from #tempprof tmp where tmp.FeeTypeId in (1,2) --OR (feetypeid=4 AND tmp.thirdpartyvendorid=5069)--INNER JOIN ThirdPartyVendors tpv on tmp.thirdpartyvendorid=tpv.ThirdPartyVendorId  where tmp.FeeTypeId in (1,2) OR (tpv.IsIntegrated=1 AND tmp.feetypeid=4)
			union all
			select ft.FeeTypeId,ft.Feetype,idrc.Amount+idrc.Surcharge as Amount,idrc.Description,idrc.Surcharge,null as ClientPassThroughFee,idrc.VendorId,tpv.VendorName as VendorName,idrc.SectionId,
			cast(case when idrc.invdetid is null then 0 else 1 end as bit) as BillToClient,1 as IsReadOnly,idrc.APNO,idrc.SectionKeyId,null as FullName,null as Employer,
			null as Investigator,cast(idrc.ModifyDate as varchar(50))as ver_by
			 from InvDetail_Reconciliation idrc WITH(NOLOCK) inner join FeeType ft on idrc.FeeTypeId=ft.FeeTypeId and idrc.Isactive=1
			inner join ThirdPartyVendors tpv WITH(NOLOCK) on idrc.VendorId=tpv.ThirdPartyVendorId 
			where idrc.SectionKeyId=@sectionkeyid and idrc.SectionId=@category AND (idrc.InvDetID IS NOT NULL OR idrc.EnteredVia='WebApp')
			drop table if exists #tempprof
END


SET NOCOUNT OFF
end
