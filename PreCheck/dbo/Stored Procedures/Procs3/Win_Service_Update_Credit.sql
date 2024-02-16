



CREATE PROCEDURE [dbo].[Win_Service_Update_Credit] @apno int,@results text, @XMLReport xml='',@PIDError bit = null,@AllowAutoOrder bit = null, @AgeLessThan23 bit = null AS
--Update credit if exist else insert
declare @getcount int;
declare @NeedsReview varchar(2);
declare @getSocialClient int;
declare @StudChk varchar(8);
declare @CLNO int;
declare @AutoOrder varchar(25);

SET @AutoOrder = 'False'

select @getSocialClient=client.social, @NeedsReview=appl.NeedsReview, @StudChk = appl.EnteredVia,  @CLNO = client.CLNO from client
inner join appl on client.clno = appl.clno where appl.apno = @apno;

SELECT      @getcount = (select count(*) from credit where apno = @apno and reptype = 's');
--print @getcount;
if (@getSocialClient = '1')
Begin
   if (@getcount > 0 )
     begin
     -- update Appl set inuse = 'Merlin' where apno = @appno
      Update Credit set report = @results, PositiveIDReport=@XMLReport where apno = @apno and reptype = 's';
   end
    else
    begin
   --  update Appl set inuse = 'Merlin' where apno = @appno
     insert into Credit (apno,vendor,Reptype,sectstat,report,last_updated,createddate,PositiveIDReport)
                values(@apno,'U','S','0',@results,getdate(),getdate(),@XMLReport);
   end
End 
--Release back to WindowService for Next Process

/*commented by Chris on 06/29/06
Update Appl
set inuse = 'Merlin_E'
where apno = @apno
*/
--Added by Chris on 06/29/06 - to release the App at the end of the Merlin process
--NB-05/2012:It could be better if conditional 
--statements are used though; eg: if(NeedsReveiw = 'W1') then update..
  
Update Appl set NeedsReview = substring(@NeedsReview,1,1) + '2', inuse = 'CNTY_S'
where (NeedsReview = @NeedsReview) and (apno = @apno); 

-- Start - Added by Deepak on 09/30/2014
-- @AllowAutoOrder --> This is to check if the Age is less than 23 and is an 'AUTOORDER' client
	--If PID Errored out but not an @AllowAutoOrder, then end the process
	if(@PIDError = 1 )
	BEGIN
		UPDATE Appl SET NeedsReview = SUBSTRING(@NeedsReview,1,1) + '3', inuse = null
		where (NeedsReview = @NeedsReview) and (apno = @apno);

	END

	--If @AllowAutoOrder is TRUE , then set the 'Completed' status
	--if ((@PIDError IS NOT NULL AND @PIDError = 0) OR @AllowAutoOrder = 1 OR @AgeLessThan23 = 1)
	--if ((@PIDError IS NOT NULL AND @PIDError = 0) OR @AgeLessThan23 = 1)
	--BEGIN
	--	SELECT @AutoOrder = ISNULL([Value], 'False') FROM clientconfiguration WHERE clno = @CLNO and configurationkey = 'AUTOORDER';
				
		--if(@AutoOrder = 'True')
		--BEGIN
		--	UPDATE Credit SET sectstat = '4' WHERE apno = @apno and reptype = 'S';
		--END
		--ELSE 
		--IF ((@AutoOrder = 'True' AND @AgeLessThan23 = 1)OR (@AutoOrder = 'False' AND @AgeLessThan23 = 1))
		If (@AgeLessThan23 = 1)
		BEGIN
			UPDATE Credit SET sectstat = '6' WHERE apno = @apno and reptype = 'S';
		END
-- End - Added by Deepak on 09/30/2014


--select substring(NeedsReview,1,1) + '4' from appl where apno = 48319
--select  NeedsReview = substring(NeedsReview,1,1) from appl where apno = 48319
--select apno from appl where needsreview is not null and needsreview <> ''


