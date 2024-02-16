-- Alter Procedure CreateCrim_New
CREATE Procedure dbo.CreateCrim_New (@folderId varchar(50),   
 @apno int,   @DateEntered Datetime)
AS
      BEGIN  
        
        
      create table #tmpCrim ( id int identity ,CNTY_NO int,IsHistoryRecord BIT,StagingId int,County varchar(75),CountyState char(2),refCountyTypeID int,CrimID int)  
        
      insert into #tmpCrim	(CNTY_NO,IsHistoryRecord,StagingId,County,CountyState,refCountyTypeID)	
      Select  P.CNTY_NO, IsNull(IsHistoryRecord,0),PublicRecordsStagingId,C.County,C.[State],refCountyTypeID
       From dbo.PrecheckFramework_PublicRecordsStaging P Inner Join  dbo.TblCounties C on P.CNTY_NO = C.CNTY_NO
      Where FolderId = @FolderId and apno = @apno and IsNull(SectionId,'') = ''
	  AND   CreatedDate >= @DateEntered    
        
 
       --select @id = 0
	     
       --while @id < (select max(id) from #tmpCrim)  
       --begin  
       --                  select @id = @id + 1  

       --                  select @CNTY_NO = CNTY_NO,@StagingId = StagingId 
       --                            from   #tmpCrim  
       --                            where  #tmpCrim.id = @id                                     
                                 
                                                                    
       --                            exec  createcrim  @apno, @CNTY_NO, @crimid OUTPUT 
       --                            if (select count(1) from dbo.Crim where Crimid = @crimid) = 0
							--			set @crimid = (select top 1 crimid from dbo.crim where apno = @apno and cnty_no = @cnty_no order by crimenteredtime desc)                                    
                                     
       --                            update dbo.PrecheckFramework_PublicRecordsStaging Set SectionID = @crimid  
       --                            Where PublicRecordsStagingId = @StagingId
								 
       --End  

  insert into Crim (Apno, CNTY_NO, County,CreatedDate) 
  Select @APNO,CNTY_NO, County,@DateEntered From #tmpCrim

  Update t Set CrimID = C.CrimID
  From #tmpCrim t inner join dbo.Crim C on t.CNTY_NO = C.CNTY_NO 
  Where c.APNO = @APNO and C.CreatedDate = @DateEntered

 --exec testfaxing @apno,@Bigcounty,@cnty_no,@CrimID


--declare @vendor1 int
--declare @vendor2 int
--declare @vendor3 int
--declare @vendor4 int
--declare @vendor5 int
--declare @vendor6 int
--declare @icounty varchar(100)
--declare @istate varchar(100)
--------------------add blurb
--declare @blurb varchar(8000)


--SET @blurb = null;
----if(@cntyno = 14)
----BEGIN
----SET @blurb = 'This search may take between 2 to 4 weeks to complete, however we will follow up periodically in an effort to expedite these results in any way possible.'
----END
----else
--if(@cntyno = 1563)
--BEGIN
--SET @blurb = 'The average turnaround time for this search is 20 business days, however we will follow up periodically in an effort to expedite these results in any way possible.'
--END
--else
--if(select count(*) from counties where isnull(country,'') not in ('','XX','USA','statewide') and cnty_no = @cntyno) > 0
--BEGIN
--SET @blurb = 'The average turnaround time for this search is 20 business days, however we will follow up periodically in an effort to expedite these results in any way possible.'
--END
--else
--if(select count(*) from counties where state = 'MA' and county not like '%statewide%' and cnty_no = @cntyno) > 0
--BEGIN
--SET @blurb = 'Due to the lack of staff within the Lower Courts of Massachusetts this search can take up to 7-10 business days to complete.  However we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
--END
--else
--if(select count(*) from counties where state = 'ME' and cnty_no = @cntyno) > 0
--BEGIN
--SET @blurb = 'Due to the lack of staff within the Courts of Maine this search can take from 7-10 business days to complete, however we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
--END
--else
--if(select count(*) from counties where state = 'AR' and cnty_no = @cntyno) > 0
--BEGIN
--SET @blurb = 'The average turnaround time for this search is 7-10 business days, however we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
--END
--else
--if(select count(*) from counties where state = 'WY' and county not like '%statewide%' and cnty_no = @cntyno) > 0
--BEGIN
--SET @blurb = 'Due to the lack of staff within the Courts of Wyoming this search can take from 7-10 business days to complete, however we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
--END
--else
--if(@cntyno = 3667)
--BEGIN
--SET @blurb = 'The average turnaround time for this search is 5 to 7 business days; however, we will follow up periodically in an effort to expedite these results.'
--END
--else
--if(select count(*) from counties where state = 'NH' and county not like '%statewide%' and cnty_no = @cntyno) > 0
--BEGIN
--SET @blurb = 'Due to the lack of staff within the Lower Courts of New Hampshire this search can take up to 7-10 business days to complete.  However we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
--END
--else
--if(@cntyno = 5)
--BEGIN
--SET @blurb = 'The average turnaround time for this search is 3 to 5 business days.'
--END
--else
--if (select count(*) from counties where state = 'VI' and cnty_no = @cntyno) > 0--(@cntyno in (2559,3304,2583,3661)) --For all Virgin Island (US and British) requests. Santosh on 04/21/2010
--BEGIN
--SET @blurb = 'The average turnaround time for this search is 20 business days; however we will follow up periodically in an effort to expedite these results in any way possible.'
--END
--else
--if(@cntyno = 3580)
--BEGIN
--SET @blurb = 'The average turnaround time for this search is 3 to 5 business days from the time of processing and will be returned from OSBI via fax.'
--END
--else
--if(@cntyno = 3732) --Added by schapyala on request by Renia - 12/05/11
--BEGIN
--SET @blurb = 'This search is conducted by the NJ State Police and can take up to 4 weeks (minimum) for completion.  No ETA is available at this time.'
--END

--SELECT      @vendor1 = 
--    CASE 
--         WHEN vendor1 IS NULL THEN 0
--         WHEN vendor1 = 0 then 0
--          ELSE vendor1
--      END,
--     @vendor2 = 
--        CASE 
--         WHEN vendor2 IS NULL THEN 0
--         WHEN vendor2 = 0 then 0
--          ELSE vendor2
--      END,
--     @vendor3  =
--        CASE 
--         WHEN vendor3 IS NULL THEN 0
--         WHEN vendor3 = 0 then 0
--          ELSE vendor3
--      END,
--     @vendor4  =
--        CASE 
--         WHEN vendor4 IS NULL THEN 0
--         WHEN vendor4 = 0 then 0
--          ELSE vendor4
--      END,
--     @vendor5  =
--        CASE 
--         WHEN vendor5 IS NULL THEN 0
--         WHEN vendor5 = 0 then 0
--          ELSE vendor5
--      END,
--@vendor6  =
--        CASE 
--         WHEN vendor6 IS NULL THEN 0
--         WHEN vendor6 = 0 then 0
--          ELSE vendor6
--      END,
--      @icounty = counties.a_county,
--      @istate = counties.state
--FROM         Counties LEFT OUTER JOIN
--                      Iris_County_Rules ON Counties.CNTY_NO = Iris_County_Rules.countystate
--WHERE     (Iris_County_Rules.Active = 1) and (iris_county_rules.countystate = @cntyno)
--and (GETDATE() between beg_date and end_date)
--if @vendor1 > 0
--   begin
--     declare @v1delivery varchar(25)
--         set @v1delivery = (select r_delivery from iris_researchers where r_id = @vendor1)
--             if (@v1delivery = 'Mail') or (@v1delivery = 'OnlineDB') or (@v1delivery = 'Call_In') or (@v1delivery = 'InHouse')
--            begin 
--                 insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor1,@v1delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--            end
--              else
--           begin
--                insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor1,@v1delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--           end
--    end
     
--if @vendor2 > 0
--       begin
--         declare @v2delivery varchar(25)
--          set @v2delivery = (select r_delivery from iris_researchers where r_id = @vendor2)
--             if (@v2delivery = 'Mail') or (@v2delivery = 'OnlineDB') or (@v2delivery = 'Call_In') or (@v2delivery = 'InHouse')
--                begin
--                  insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                    values(@appno,@county,@cntyno,@vendor2,@v2delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb,@Private_Notes)
--                 end
--             else
--                begin
--                     insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor2,@v2delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb,@Private_Notes)
--              end
--       end


--if @vendor3 > 0
--  begin
--       declare @v3delivery varchar(25)
--       set @v3delivery = (select r_delivery from iris_researchers where r_id = @vendor3)
--           if (@v3delivery = 'Mail') or (@v3delivery = 'OnlineDB') or (@v3delivery = 'Call_In') or (@v3delivery = 'InHouse')
--     begin         
--          insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor3,@v3delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--    end
--             else
--            begin
--      insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor3,@v3delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--            end
--           end

--if @vendor4 > 0
--   begin
--    declare @v4delivery varchar(25)
--    set @v4delivery = (select r_delivery from iris_researchers where r_id = @vendor3)
--           if (@v4delivery = 'Mail') or (@v4delivery = 'OnlineDB') or (@v4delivery = 'Call_In') or (@v4delivery = 'InHouse')
--            begin
--             insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor4,@v4delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--             end
--           else
--         begin
--            insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor4,@v4delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--        end
--end
--if @vendor5 > 0
--  begin
--declare @v5delivery varchar(25)
--set @v5delivery = (select r_delivery from iris_researchers where r_id = @vendor5)
--     if (@v5delivery = 'Mail') or (@v5delivery = 'OnlineDB') or (@v5delivery = 'Call_In') or (@v5delivery = 'InHouse')
--     begin
--        insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor5,@v5delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--     end
--     else
--      begin
-- insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor5,@v5delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--      end
--    end
--if @vendor6 > 0
--  begin
--declare @v6delivery varchar(25)
--   set @v6delivery = (select r_delivery from iris_researchers where r_id = @vendor6)
--   if (@v6delivery = 'Mail') or (@v6delivery = 'OnlineDB') or (@v6delivery = 'Call_In') or (@v6delivery = 'InHouse')
--   begin 
--  insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor6,@v6delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)  
--   end
--   else
--   begin
--   insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                values(@appno,@county,@cntyno,@vendor6,@v6delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)  
--  end  
--end--------------------------- THE END-----------------------------------
------------------ CHECK FOR DEFAULT --------------------
--Declare @c_vendorid int
--Declare @c_delivery varchar(50)
--Declare @c_default varchar(4)
--Declare @c_state varchar(100)
--Declare @c_county varchar(100)
--Declare @altVendor int -- Vendor Rule Id
--Declare @altvendorbeg datetime
--Declare @altvendorend datetime
--Declare @altvendoractive varchar(4)
--Declare @checkreadytosend varchar(2)

--if (@vendor1 + @vendor2 + @vendor3 + @vendor4 + @vendor5 + @vendor6) is null
--        BEGIN
--                SELECT      @c_vendorid = Iris_Researcher_Charges.Researcher_id, @c_delivery =  Iris_Researchers.R_Delivery,@c_county = 
--                  Counties.CNTY_NO, @altvendor = Iris_Researchers.vendorruleid,@altvendorbeg = Iris_Researchers.vendorrulestartdate,
--                 @altvendorend = iris_researchers.vendorruleenddate,@altvendoractive = iris_researchers.vendorruleactive,
--                  @checkreadytosend =
--                     case iris_researchers.r_delivery
--                     when 'Mail' then 0
--                     when 'OnlineDB' then 0
--                     when 'Call_In' then 0
--                    when 'InHouse' then 0
--                     else '0'
--                    end
                  
--                   FROM         Counties LEFT OUTER JOIN
--                   Iris_Researcher_Charges ON Counties.CNTY_NO = Iris_Researcher_Charges.cnty_no LEFT OUTER JOIN
--                   Iris_Researchers ON Iris_Researcher_Charges.Researcher_id = Iris_Researchers.R_id
--                   where (iris_researcher_charges.cnty_no = @cntyno) AND (Iris_Researcher_Charges.Researcher_Default = 'yes')
--         If (@altvendoractive = '1' ) and (getdate() between @altvendorbeg and @altvendorend)
--                 begin
--                    set @c_vendorid = @altvendor
--                         insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                    values(@appno,@county,@c_county,@c_vendorid,@c_delivery,'Yes','yes',@checkreadytosend,@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--                 end
--             else
--                 Begin
--                         insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
--                   values(@appno,@county,@cntyno,@c_vendorid,@c_delivery,'No','yes',@checkreadytosend,@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
--                end
--        END

--DELETE FROM Crim where crimid = @crimid





        
      UPDATE   
       pubrec  
      SET   
       County = prstg.County  
       ,Clear = prstg.Clear  
       ,Ordered = prstg.Ordered  
       ,Name = prstg.Name  
       ,DOB = prstg.DOB  
       ,SSN = prstg.SSN  
       ,CaseNo = prstg.CaseNo  
       ,Date_Filed = prstg.Date_Filed  
       ,Degree = Case When prstg.Clear = 'R' Then NULL Else prstg.Degree  END
       ,Offense = prstg.Offense  
       ,Disposition = prstg.Disposition  
       ,Sentence = prstg.Sentence  
       ,Fine = prstg.Fine  
       ,Disp_Date = prstg.Disp_Date  
       ,Priv_Notes = cast(prstg.Priv_Notes as varchar(max))  
       ,Pub_Notes = cast(prstg.Pub_Notes as varchar(max))  
       ,IsHistoryRecord = prstg.IsHistoryRecord  
       ,IsHidden = IsNull(prstg.IsHidden,0)  
       ,InUse = null --prstg.InUse  
       ,Report = cast(prstg.Report as varchar(max))  
       ,[CRIM_SpecialInstr] = cast(prstg.[CRIM_SpecialInstr] as varchar(max))  
       ,[Last_Updated] =  Current_Timestamp  
	   ,AdmittedRecord = IsNull(prstg.AdmittedRecord,0)
	    FROM  
       [dbo].[Crim] pubrec         
       JOIN   
       [dbo].[PrecheckFramework_PublicRecordsStaging] prstg   
       ON  
       prstg.Apno = pubrec.Apno and prstg.SectionId = pubrec.CrimId   
      where IsNull(prstg.SectionID,'') <> ''  
	  and prstg.FolderId = @folderId 
	  and prstg.CreatedDate >= @DateEntered 
        
		DELETE FROM   
			[dbo].[PrecheckFramework_PublicRecordsStaging]  
		WHERE  FolderId = @FolderId and apno = @apno 
		and    CreatedDate >= @DateEntered



                 
     END 
	 
	 --Temp solution to update sex offender
	 --added USFederal, FedBankruptcy, and USCivil to this logic - schapyala 02/05/14
	 Update [dbo].[Crim]
	 Set Clear = 'R'
	 Where cnty_no in (2480,2738,229,2737) AND Apno = @apno and Isnull(Clear,'')=''
