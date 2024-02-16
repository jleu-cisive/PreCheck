
-- =============================================
-- Author:		Douglas Degenaro
-- Create date: 2/28/2014
-- Description:	
-- =============================================


-- =============================================
-- Author:		Douglas Degenaro
-- Updated date: 1/2/2015
-- Description:	Change to add Warrant Status put in private notes, needs to have own control on CEQ in the future
-- =============================================


CREATE procedure [dbo].[AIMS_Crim_Review_Insert]
@CrimID int, 
@CaseNo varchar(50) = null,
@Date_Filed datetime = null,
@Degree varchar(1) = null,
@Offense varchar(1000) = null,
@Disposition varchar(500) = null,
@Disp_Date datetime = null,
@NotesCaseInformation varchar(max) = null,
@AdditionalInformation varchar(1000) = null,
@WarrantStatus varchar(100)= null,
@NameonRecord varchar(300) = null,
@SSN_OnRecord varchar(11) = null,
@DOB_OnRecord varchar(12)= null,
@Sentence varchar(1000) = null,
@Fine varchar(50) = null

as
begin
	declare @DOB datetime;
	declare @SSN varchar(11);	
	--declare @Sentence varchar(1000);
	--declare @Fine varchar(50);	
	declare @CrimStatus varchar(10);
	declare @SpecialIntr varchar(max) = ''	
	
	Select 
		@DOB = DOB,
		@SSN = @SSN,
		--@Sentence = Sentence,
		--@Fine = Fine,		
		@CrimStatus = 'F',
		@SpecialIntr = cast(CRIM_SpecialInstr as varchar(MAX))
	FROM 
		dbo.Crim 
	WHERE 
		CrimID = @CrimID    
		
	
	if (Len(IsNull(@AdditionalInformation,'')) > 0)			
	UPDATE 
		dbo.Crim
	SET
		CRIM_SpecialInstr = ISNULL(@SpecialIntr,' ') + ';Additional Information:' + @AdditionalInformation,
		Priv_Notes =  IsNull(Priv_Notes,' ') + ';****WARRANT STATUS*****:' + IsNull(@WarrantStatus,' ')						
	Where 
		CrimID = @CrimID
	    					
	insert into dbo.Crim_Review (
		crimid, 
		dob, 
		ssn, 
		caseno, 
		Date_Filed, 
		Degree, 
		Offense, 
		Disposition, 
		Sentence, 
		Fine, 
		Disp_Date, 
		NotesCaseInformation, 
		AdditionalInformation, 
		WarrantStatus, 
		NameonRecord,
		ssn_onrecord, 
		dob_onrecord, 
		crimstatus, 
		aims_reviewdate
		)
	Select
		@CrimID, 
		@DOB, 
		@SSN, 
		@CaseNo, 
		@Date_Filed, 
		@Degree, 
		@Offense, 
		@Disposition, 
		@Sentence,
		@Fine, 
		@Disp_Date, 
		@NotesCaseInformation,
		@AdditionalInformation, 
		@WarrantStatus, @NameonRecord, 
		@SSN_OnRecord, 
		@DOB_OnRecord, 
		@CrimStatus, 
		GETDATE()

end

