-- Alter Procedure testfaxing

CREATE PROCEDURE [dbo].[testfaxing] @appno int,@county varchar(40),@cntyno int, @crimid int,@Clear varchar(1) = null,@CRIM_SpecialInstr varchar(8000)=null,@ClientAdjudicationStatus int = null , @Private_Notes varchar(8000) = null AS
--select * from dbo.faxworkorders(@icounty,@istate)
--select * from researcher_county_rules where county = 'brazos' and state = 'tx'
---------------------------------------------------------------------
-- CHECK COUNTY RULE FIRST--


declare @vendor1 int
declare @vendor2 int
declare @vendor3 int
declare @vendor4 int
declare @vendor5 int
declare @vendor6 int
declare @icounty varchar(100)
declare @istate varchar(100)
------------------add blurb
declare @blurb varchar(8000)


SET @blurb = null;
--if(@cntyno = 14)
--BEGIN
--SET @blurb = 'This search may take between 2 to 4 weeks to complete, however we will follow up periodically in an effort to expedite these results in any way possible.'
--END
--else
if(@cntyno = 1563)
	BEGIN
	SET @blurb = 'The average turnaround time for this search is 20 business days, however we will follow up periodically in an effort to expedite these results in any way possible.'
	END
-- Added by Radhika Dereddy on 03/08/2018 Per Joe
else if(@cntyno = 209)
	BEGIN
	SET @blurb = 'Due to changes made by the court clerk for this jurisdiction, only the past 5 years are able to be searched and reported.  Any record predating this time frame may not be included in these results due to the courts policies and procedures.'
	END
-- Added by Prasanna on 05/21/2018
ELSE if(@cntyno in(24,164,186,205,244,249,263,264,3403,357,436,477,718,927,3508,1011,1021,1035,1095,1339,1404,1426,1509,1564,1711,1866,1999,2132,2179,2266,3341,2362,2505,2734,
2847,3133,3168,3169,3174,3208,3245,3344,3452,3585,3587))
	BEGIN
	SET @blurb = 'Court records in Idaho counties are being migrated to the iCourt Portal, as directed by the Idaho Court Administrative Rule 32.  Identifying information on this public site is limited to name and year of birth only.  Currently, some of the courts that have migrated records will assist with verifying full dates of birth but require that requestors follow very specific and time consuming instructions. Therefore, there could an impact to search completion times. Additionally, some Idaho county courts refuse to provide any additional identifying information.  Because a match based solely on name and year of birth does not meet accuracy standards for criminal record reporting, such records will not be reported unless a third, reliable identifier can be established.'
	END
else
if(select count(*) from dbo.TblCounties where state = 'MA' and county not like '%statewide%' and cnty_no = @cntyno) > 0
	BEGIN
	SET @blurb = 'Due to the lack of staff within the Lower Courts of Massachusetts this search can take up to 7-10 business days to complete.  However we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
	END
else
if(select count(*) from dbo.TblCounties where state = 'ME' and cnty_no = @cntyno) > 0
	BEGIN
	SET @blurb = 'Due to the lack of staff within the Courts of Maine this search can take from 7-10 business days to complete, however we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
	END
else
if(select count(*) from dbo.TblCounties where state = 'AR' and cnty_no = @cntyno) > 0
	BEGIN
	SET @blurb = 'The average turnaround time for this search is 7-10 business days, however we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
	END
else
if(select count(*) from dbo.TblCounties where state = 'WY' and county not like '%statewide%' and cnty_no = @cntyno) > 0
	BEGIN
	SET @blurb = 'Due to the lack of staff within the Courts of Wyoming this search can take from 7-10 business days to complete, however we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
	END
else
if(@cntyno = 3667)
	BEGIN
	SET @blurb = 'The average turnaround time for this search is 5 to 7 business days; however, we will follow up periodically in an effort to expedite these results.'
	END
else
if(select count(*) from dbo.TblCounties where state = 'NH' and county not like '%statewide%' and cnty_no = @cntyno) > 0
	BEGIN
	SET @blurb = 'Due to the lack of staff within the Lower Courts of New Hampshire this search can take up to 7-10 business days to complete.  However we will follow up with the courts periodically in an effort to expedite these results in any way possible.'
	END
else
if(@cntyno = 5)
	BEGIN
	SET @blurb = 'The average turnaround time for this search is 3 to 5 business days.'
	END
else
if (select count(*) from dbo.TblCounties where state = 'VI' and cnty_no = @cntyno) > 0--(@cntyno in (2559,3304,2583,3661)) --For all Virgin Island (US and British) requests. Santosh on 04/21/2010
	BEGIN
	SET @blurb = 'The average turnaround time for this search is 20 business days; however we will follow up periodically in an effort to expedite these results in any way possible.'
	END
else
if(@cntyno = 3580)
	BEGIN
	SET @blurb = 'The average turnaround time for this search is 3 to 5 business days from the time of processing and will be returned from OSBI via fax.'
	END
else
if(@cntyno = 3732) --Added by schapyala on request by Renia - 12/05/11
	BEGIN
	SET @blurb = 'This search is conducted by the NJ State Police and can take up to 4 weeks (minimum) for completion.  No ETA is available at this time.'
	END
else
--if(select count(*) from counties where  state = 'PR' and cnty_no = @cntyno) > 0
--	BEGIN
--		SET @blurb = 'Due to the hurricane devastation we are currently experiencing extended delays in receiving results from this jurisdiction. The court fulfills requests in the order which they are received and has reported a backlog of pending items. Updates will be provided in this forum as they are made available to us so it is possible that the listed ETA will change over time. We sincerely appreciate your patience as we work to provide a thorough and accurate background report.'
--		--SET @blurb = 'We are currently experiencing extended delays in receiving results from this jurisdiction. The court fulfills requests in the order which they are received and has reported a backlog of pending items.  At present, we have been informed to expect results in a period ranging from 30 to 120 business days. Updates will be provided in this forum as they are made available to us so it is possible that the listed ETA will change over time. We sincerely appreciate your patience as we work to provide a thorough and accurate background report.'
--	END
--else
if(@cntyno = 707)
	BEGIN
		SET @blurb = 'Due to changes made by the court clerk for this jurisdiction, only the Circuit Court will be searched. A District Court search is not included in these results due to the court’s policies and procedures.'
	END
else
if(@cntyno = 3670)
	BEGIN
		SET @blurb = 'Please be aware of possible delays for this criminal search. Due to the process within the State police Department of Illinois, the Statewide Illinois search may take up to 45 business days to complete; however, we will follow up with the courts regularly in an effort to expedite these results in any way possible.  Please contact your Client Account Manager for further information. '
	END
else
if(select count(*) from dbo.TblCounties where isnull(country,'') not in ('','XX','USA','statewide','XXXXXX') and cnty_no = @cntyno) > 0
	BEGIN
	SET @blurb = 'The average turnaround time for this search is 20 business days, however we will follow up periodically in an effort to expedite these results in any way possible.'
	END

/*04/07/2020 - schapyala - COVID RELATED BLURBS AND SETTING THE STATUS*/
/* uncomment below and edit the SQL
if(select count(1) from counties where  state in ('VT') and cnty_no = @cntyno) > 0
	BEGIN
		SET @blurb = 'This search is unable to be completed at this time due to the courthouses being unavailable in response to COVID-19.  Please contact your Client Account Manager if you have any questions regarding how we can track this and potentially pursue this in the future.'
		
		If (Select c.affiliateid from Appl a inner join client c on a.clno = c.clno 
											 inner join refAffiliate r on c.AffiliateID = r.AffiliateID
								 Where a.APNO = @appno) not in (147,149,200,252,253) --exclude CHI, Dignity and Common spirit			
			SET @Clear = 'S'

	END

--if(@cntyno in (852))
--	BEGIN
--		SET @blurb = 'This search is unable to be completed at this time due to the courthouses being unavailable in response to COVID-19.  Please contact your Client Account Manager if you have any questions regarding how we can track this and potentially pursue this in the future.'
		
--		If (Select c.affiliateid from Appl a inner join client c on a.clno = c.clno 
--											 inner join refAffiliate r on c.AffiliateID = r.AffiliateID
--								 Where a.APNO = @appno) not in (147,149,200,252,253) --exclude CHI, Dignity and Common spirit			
--			SET @Clear = 'S'

--	END

END COVID RELATED BLURBS AND SETTING THE STATUS*/

-- below update is added to add date to the Publicnotes updates above-- per DANA - added by kiran on 10/27/2014
set @blurb =  CONVERT (VARCHAR(10), GETDATE(), 101) + ' - ' + @blurb

--County rules is used to send the same search to multiple vendors at the same time - upper court and lower court as an example - schapyala - 05/29/2019
SELECT      @vendor1 = 
    CASE 
         WHEN vendor1 IS NULL THEN 0
         WHEN vendor1 = 0 then 0
          ELSE vendor1
      END,
     @vendor2 = 
        CASE 
         WHEN vendor2 IS NULL THEN 0
         WHEN vendor2 = 0 then 0
          ELSE vendor2
      END,
     @vendor3  =
        CASE 
         WHEN vendor3 IS NULL THEN 0
         WHEN vendor3 = 0 then 0
          ELSE vendor3
      END,
     @vendor4  =
        CASE 
         WHEN vendor4 IS NULL THEN 0
         WHEN vendor4 = 0 then 0
          ELSE vendor4
      END,
     @vendor5  =
        CASE 
         WHEN vendor5 IS NULL THEN 0
         WHEN vendor5 = 0 then 0
          ELSE vendor5
      END,
@vendor6  =
        CASE 
         WHEN vendor6 IS NULL THEN 0
         WHEN vendor6 = 0 then 0
          ELSE vendor6
      END,
      @icounty = TblCounties.a_county,
      @istate = TblCounties.state
FROM         dbo.TblCounties LEFT OUTER JOIN
                      Iris_County_Rules ON TblCounties.CNTY_NO = Iris_County_Rules.countystate
WHERE     (Iris_County_Rules.Active = 1) and (iris_county_rules.countystate = @cntyno)
and (GETDATE() between beg_date and end_date)
if @vendor1 > 0
   begin
     declare @v1delivery varchar(25)
         set @v1delivery = (select r_delivery from iris_researchers where r_id = @vendor1)
             if (@v1delivery = 'Mail') or (@v1delivery = 'OnlineDB') or (@v1delivery = 'Call_In') or (@v1delivery = 'InHouse')
            begin 
                 insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor1,@v1delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
            end
              else
           begin
                insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor1,@v1delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
           end
    end
     
if @vendor2 > 0
       begin
         declare @v2delivery varchar(25)
          set @v2delivery = (select r_delivery from iris_researchers where r_id = @vendor2)
             if (@v2delivery = 'Mail') or (@v2delivery = 'OnlineDB') or (@v2delivery = 'Call_In') or (@v2delivery = 'InHouse')
                begin
                  insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                    values(@appno,@county,@cntyno,@vendor2,@v2delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb,@Private_Notes)
                 end
             else
                begin
                     insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor2,@v2delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb,@Private_Notes)
              end
       end


if @vendor3 > 0
  begin
       declare @v3delivery varchar(25)
       set @v3delivery = (select r_delivery from iris_researchers where r_id = @vendor3)
           if (@v3delivery = 'Mail') or (@v3delivery = 'OnlineDB') or (@v3delivery = 'Call_In') or (@v3delivery = 'InHouse')
     begin         
          insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor3,@v3delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
    end
             else
            begin
      insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor3,@v3delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
            end
           end

if @vendor4 > 0
   begin
    declare @v4delivery varchar(25)
    set @v4delivery = (select r_delivery from iris_researchers where r_id = @vendor3)
           if (@v4delivery = 'Mail') or (@v4delivery = 'OnlineDB') or (@v4delivery = 'Call_In') or (@v4delivery = 'InHouse')
            begin
             insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor4,@v4delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
             end
           else
         begin
            insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor4,@v4delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
        end
end
if @vendor5 > 0
  begin
declare @v5delivery varchar(25)
set @v5delivery = (select r_delivery from iris_researchers where r_id = @vendor5)
     if (@v5delivery = 'Mail') or (@v5delivery = 'OnlineDB') or (@v5delivery = 'Call_In') or (@v5delivery = 'InHouse')
     begin
        insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor5,@v5delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
     end
     else
      begin
 insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor5,@v5delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
      end
    end
if @vendor6 > 0
  begin
declare @v6delivery varchar(25)
   set @v6delivery = (select r_delivery from iris_researchers where r_id = @vendor6)
   if (@v6delivery = 'Mail') or (@v6delivery = 'OnlineDB') or (@v6delivery = 'Call_In') or (@v6delivery = 'InHouse')
   begin 
  insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor6,@v6delivery,'Yes','Yes','0',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)  
   end
   else
   begin
   insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                values(@appno,@county,@cntyno,@vendor6,@v6delivery,'Yes','Yes',@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)  
  end  
end--------------------------- THE END-----------------------------------
---------------- CHECK FOR DEFAULT --------------------
--vendor rule is used to send the serch to an alternate vendor between a specified period of time.- schapyala -05/29/2019
Declare @c_vendorid int
Declare @c_delivery varchar(50)
Declare @c_default varchar(4)
Declare @c_state varchar(100)
Declare @c_county varchar(100)
Declare @altVendor int -- Vendor Rule Id
Declare @altvendorbeg datetime
Declare @altvendorend datetime
Declare @altvendoractive varchar(4)
Declare @checkreadytosend varchar(2)

if (@vendor1 + @vendor2 + @vendor3 + @vendor4 + @vendor5 + @vendor6) is null
        BEGIN
                SELECT      @c_vendorid = Iris_Researcher_Charges.Researcher_id, @c_delivery =  Iris_Researchers.R_Delivery,@c_county = 
                  TblCounties.CNTY_NO, @altvendor = Iris_Researchers.vendorruleid,@altvendorbeg = Iris_Researchers.vendorrulestartdate,
                 @altvendorend = iris_researchers.vendorruleenddate,@altvendoractive = iris_researchers.vendorruleactive,
                  @checkreadytosend =
                     case iris_researchers.r_delivery
                     when 'Mail' then 0
                     when 'OnlineDB' then 0
                     when 'Call_In' then 0
                    when 'InHouse' then 0
                     else '0'
                    end
                  
                   FROM         dbo.TblCounties LEFT OUTER JOIN
                   Iris_Researcher_Charges ON TblCounties.CNTY_NO = Iris_Researcher_Charges.cnty_no LEFT OUTER JOIN
                   Iris_Researchers ON Iris_Researcher_Charges.Researcher_id = Iris_Researchers.R_id
                   where (iris_researcher_charges.cnty_no = @cntyno) AND (Iris_Researcher_Charges.Researcher_Default = 'yes')
         If (@altvendoractive = '1' ) and (getdate() between @altvendorbeg and @altvendorend)
                 begin
                    set @c_vendorid = @altvendor
                         insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                    values(@appno,@county,@c_county,@c_vendorid,@c_delivery,'Yes','yes',@checkreadytosend,@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
                 end
             else
                 Begin
                         insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID,Clear,CRIM_SpecialInstr,ClientAdjudicationStatus,pub_notes, priv_notes)
                   values(@appno,@county,@cntyno,@c_vendorid,@c_delivery,'No','yes',@checkreadytosend,@crimid,@Clear,@CRIM_SpecialInstr,@ClientAdjudicationStatus,@blurb, @Private_Notes)
                end
        END

DELETE FROM Crim where crimid = @crimid
