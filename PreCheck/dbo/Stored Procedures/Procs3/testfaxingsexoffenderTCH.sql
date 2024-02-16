-- Alter Procedure testfaxingsexoffenderTCH

CREATE PROCEDURE [dbo].[testfaxingsexoffenderTCH] @appno int,@county varchar(25),@cntyno int, @crimid int, @state varchar(2) AS
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
                 insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor1,@v1delivery,'Yes','Yes','0',@crimid, @state,'R')
            end
              else
           begin
                insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID, crim_specialinstr ,Clear )
                values(@appno,@county,@cntyno,@vendor1,@v1delivery,'Yes','Yes',@crimid, @state,'R')
           end
    end
     
if @vendor2 > 0
       begin
         declare @v2delivery varchar(25)
          set @v2delivery = (select r_delivery from iris_researchers where r_id = @vendor2)
             if (@v2delivery = 'Mail') or (@v2delivery = 'OnlineDB') or (@v2delivery = 'Call_In') or (@v2delivery = 'InHouse')
                begin
                  insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID, crim_specialinstr,Clear )
                    values(@appno,@county,@cntyno,@vendor2,@v2delivery,'Yes','Yes','0',@crimid, @state,'R')
                 end
             else
                begin
                     insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor2,@v2delivery,'Yes','Yes',@crimid, @state,'R')
              end
       end


if @vendor3 > 0
  begin
       declare @v3delivery varchar(25)
       set @v3delivery = (select r_delivery from iris_researchers where r_id = @vendor3)
           if (@v3delivery = 'Mail') or (@v3delivery = 'OnlineDB') or (@v3delivery = 'Call_In') or (@v3delivery = 'InHouse')
     begin         
          insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor3,@v3delivery,'Yes','Yes','0',@crimid, @state,'R')
    end
             else
            begin
      insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor3,@v3delivery,'Yes','Yes',@crimid, @state,'R')
            end
           end

if @vendor4 > 0
   begin
    declare @v4delivery varchar(25)
    set @v4delivery = (select r_delivery from iris_researchers where r_id = @vendor3)
           if (@v4delivery = 'Mail') or (@v4delivery = 'OnlineDB') or (@v4delivery = 'Call_In') or (@v4delivery = 'InHouse')
            begin
             insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor4,@v4delivery,'Yes','Yes','0',@crimid, @state,'R')
             end
           else
         begin
            insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor4,@v4delivery,'Yes','Yes',@crimid, @state,'R')
        end
end
if @vendor5 > 0
  begin
declare @v5delivery varchar(25)
set @v5delivery = (select r_delivery from iris_researchers where r_id = @vendor5)
     if (@v5delivery = 'Mail') or (@v5delivery = 'OnlineDB') or (@v5delivery = 'Call_In') or (@v5delivery = 'InHouse')
     begin
        insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor5,@v5delivery,'Yes','Yes','0',@crimid, @state,'R')
     end
     else
      begin
 insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor5,@v5delivery,'Yes','Yes',@crimid, @state,'R')
      end
    end
if @vendor6 > 0
  begin
declare @v6delivery varchar(25)
   set @v6delivery = (select r_delivery from iris_researchers where r_id = @vendor6)
   if (@v6delivery = 'Mail') or (@v6delivery = 'OnlineDB') or (@v6delivery = 'Call_In') or (@v6delivery = 'InHouse')
   begin 
  insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor6,@v6delivery,'Yes','Yes','0',@crimid, @state,'R')
   end
   else
   begin
   insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,parentCrimID, crim_specialinstr,Clear )
                values(@appno,@county,@cntyno,@vendor6,@v6delivery,'Yes','Yes',@crimid, @state,'R') 
  end  
end--------------------------- THE END-----------------------------------
---------------- CHECK FOR DEFAULT --------------------
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
                         insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID, crim_specialinstr,Clear )
                    values(@appno,@county,@c_county,@c_vendorid,@c_delivery,'Yes','yes',@checkreadytosend,@crimid, @state,'R')
                 end
             else
                 Begin
                         insert into crim(apno,county,cnty_no,vendorid,deliverymethod,b_rule,iris_rec,readytosend,parentCrimID, crim_specialinstr,Clear )
                   values(@appno,@county,@cntyno,@c_vendorid,@c_delivery,'No','yes',@checkreadytosend,@crimid, @state,'R')
                end
        END

delete from crim where crimid = @crimid
