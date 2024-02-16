


CREATE PROCEDURE [dbo].[AppendBlurbToAppl] 
@crimid int
as

declare @ptr binary(16)
declare @blurb varchar(3000)
declare @apno int
declare @pnotes bit

--
--select   @ptr = textptr(a.pub_notes), @blurb =  b.blurb, @apno=a.apno, @pnotes = (case when a.pub_notes is null then  0 else 1 end)
--from appl a inner join sexoffenderblurb b on a.state=b.state inner join crim c on c.apno=a.apno 
--where c.crimid = @crimid and a.inuse ='IRIS' and c.cnty_no = 2480
--
----set @blurb = @blurb  + CHAR(13)+CHAR(10) + 'Please note that the Alabama Sex Offender Registry site is currently unavailable, and does not have an anticipated date of being made available. At this time we are unable to complete our Sex Offender search to include results from the state of Alabama; however we will continue to perform a National Sex Offender registry search for ALL other states.  Upon the restoration of the state’s and/or national site this search will be completed, and your report will be updated.'
--set @blurb = ''
--if @pnotes = 0  begin 
--
--
--
--
--UPDATE APPL
--SET PUB_NOTES = @blurb where  apno=@apno
--
--end
--
--if @pnotes = 1 begin
--
--set @blurb = char(10) + @blurb
-- updatetext appl.pub_notes @ptr null 0  @blurb

--end


