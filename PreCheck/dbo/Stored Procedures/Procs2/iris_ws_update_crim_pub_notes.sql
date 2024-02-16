CREATE PROCEDURE [dbo].[iris_ws_update_crim_pub_notes]
    @crim_id BIGINT,
    @order_status VARCHAR(35),
    @result_status VARCHAR(35),
    @case_number VARCHAR(50),
    @degree VARCHAR(500),
    @disposition VARCHAR(500),
    --@disposed_on DATETIME,
    @disposed_on VARCHAR(20),
    @filed_on DATETIME,
    @offense VARCHAR(1000),
    @sentence VARCHAR(1000)
AS
DECLARE @CRLF CHAR(2);
DECLARE @pub_notes VARCHAR(3000);
DECLARE @temp_disposition VARCHAR(1000);
DECLARE @temp_degree VARCHAR(500);
DECLARE @temp_sentence VARCHAR(1000);
DECLARE @temp_order_status VARCHAR(35);
DECLARE @temp_result_status VARCHAR(35);
DECLARE @temp_offense VARCHAR(1000);

BEGIN
   /* SET @temp_disposition = CASE
        WHEN @disposition = 'Acquitted' THEN 'Acquitted'
        WHEN @disposition = 'AdjournedToX' THEN 'AdjournedToX'
        WHEN @disposition = 'AdjudicatedGuilty' THEN 'AdjudicatedGuilty'
        WHEN @disposition = 'AdjudicationWithheld' THEN 'AdjudicationWithheld'
        WHEN @disposition = 'ArdProgram' THEN 'ArdProgram'
        WHEN @disposition = 'Bail_BondForfeiture' THEN 'Bail_BondForfeiture' 
        WHEN @disposition = 'ConditionalDischarge' THEN 'ConditionalDischarge'
        WHEN @disposition = 'ConsentDecreeJuvenile' THEN 'ConsentDecreeJuvenile'
        WHEN @disposition = 'Convicted' THEN 'Convicted'
        WHEN @disposition = 'DeadDocket' THEN 'DeadDocket'
        WHEN @disposition = 'DeferredJudgment' THEN 'DeferredJudgment'
        WHEN @disposition = 'Dismissed' THEN 'Dismissed'
        WHEN @disposition = 'DisposedByWaiver' THEN 'DisposedByWaiver'
        WHEN @disposition = 'Dropped' THEN 'Dropped'
        WHEN @disposition = 'FugitiveFile' THEN 'FugitiveFile'
        WHEN @disposition = 'Guilty' THEN 'Guilty'
        WHEN @disposition = 'GuiltyInAbsentia' THEN 'GuiltyInAbsentia'
        WHEN @disposition = 'Ignored' THEN 'Ignored'
        WHEN @disposition = 'Infraction' THEN 'Infraction'
        WHEN @disposition = 'LetterOfRealeaseFiled' THEN 'LetterOfRealeaseFiled'
        WHEN @disposition = 'MisdInterventionProgram' THEN 'MisdInterventionProgram'
        WHEN @disposition = 'NoAction' THEN 'NoAction'
        WHEN @disposition = 'NoBilled' THEN 'NoBilled'
        WHEN @disposition = 'NoFindingOfGuilt' THEN 'NoFindingOfGuilt'
        WHEN @disposition = 'NonformationFiled' THEN 'NonformationFiled'
        WHEN @disposition = 'NoPapered' THEN 'NoPapered'
        WHEN @disposition = 'NolleProsse' THEN 'NolleProsse'
        WHEN @disposition = 'NoloContendre' THEN 'NoloContendre'
        WHEN @disposition = 'NonAdjudicationOfGuilt' THEN 'NonAdjudicationOfGuilt'
        WHEN @disposition = 'NotGuilty' THEN 'NotGuilty'
        WHEN @disposition = 'OrderForArrest' THEN 'OrderForArrest'
        WHEN @disposition = 'Other' THEN 'Other'
        WHEN @disposition = 'Pending' THEN 'Pending'
        WHEN @disposition = 'PledGuilty' THEN 'PledGuilty'
        WHEN @disposition = 'PledNolloContendre' THEN 'PledNolloContendre'
        WHEN @disposition = 'PrayerForJudgement' THEN 'PrayerForJudgement'
        WHEN @disposition = 'PerePaid' THEN 'PerePaid'
        WHEN @disposition = 'PreTrialIntervention' THEN 'PreTrialIntervention'
        WHEN @disposition = 'ProcessOther' THEN 'ProcessOther'
        WHEN @disposition = 'Remanded' THEN 'Remanded'
        WHEN @disposition = 'Responsible' THEN 'Responsible'
        WHEN @disposition = 'StrickenOffLeave' THEN 'StrickenOffLeave'
        WHEN @disposition = 'StetDocket' THEN 'StetDocket'
        WHEN @disposition = 'TransferredToCaseNumber' THEN 'TransferredToCaseNumber'
        WHEN @disposition = 'TransferredToGrandJury' THEN 'TransferredToGrandJury'
        WHEN @disposition = 'WaivedPledGuilty' THEN 'WaivedPledGuilty'
        WHEN @disposition = 'Waiver' THEN 'Waiver'
        ELSE 'unknown'
    END */

  /*  SET @temp_degree = CASE
        WHEN @degree = 'felony' THEN 'felony'
        WHEN @degree = 'forfeiture' THEN 'forfeiture'
        WHEN @degree = 'infraction' THEN 'infraction'
        WHEN @degree = 'misdemeanor' THEN 'misdemeanor'
        WHEN @degree = 'pettyOffence' THEN 'pettyOffence'
        WHEN @degree = 'summary' THEN 'summary'
        WHEN @degree = 'traffic' THEN 'traffic'
        WHEN @degree = 'violation' THEN 'violation'
        WHEN @degree = 'capias' THEN 'capias'
        WHEN @degree = 'showCause' THEN 'showCause'
        WHEN @degree = 'ordinanceViolation' THEN 'ordinanceViolation'
        WHEN @degree = 'Sealed' THEN 'ordinanceViolation'
        WHEN @degree = 'felonyReducedToMisdemeanor' THEN 'felonyReducedToMisdemeanor'
        WHEN @degree = 'misdemeanorReducedToViolation' THEN 'misdemeanorReducedToViolation'
        WHEN @degree = 'unknown' THEN 'unknown'
        ELSE 'unknown'
    END */

    SET @temp_order_status = CASE
        WHEN @order_status = 'New' THEN 'New'
        WHEN @order_status = 'InProgress' THEN 'InProgress'
        WHEN @order_status = 'Cancelled' THEN 'Cancelled'
        WHEN @order_status = 'Suspended' THEN 'Suspended'
        WHEN @order_status = 'Completed' THEN 'Completed'
        WHEN @order_status = 'Fulfilled' THEN 'Fulfilled'
        WHEN @order_status = 'Delayed' THEN 'Delayed'
        WHEN @order_status = 'Hold' THEN 'Hold'
        ELSE 'unknown'
    END

    SET @temp_result_status = CASE
        WHEN @result_status = 'Pass' THEN 'Pass'
        WHEN @result_status = 'Fail' THEN 'Fail'
        WHEN @result_status = 'Review' THEN 'Review'
        WHEN @result_status = 'Hit' THEN 'Hit'
        WHEN @result_status = 'Clear' THEN 'Clear'
        WHEN @result_status = 'UnableToContact' THEN 'UnableToContact'
        WHEN @result_status = 'UnableToVerify' THEN 'UnableToVerify'
        ELSE 'unknown'
    END

    SET @CRLF = char(13) + char(10);

    SET @temp_sentence = CASE
      WHEN @sentence IS NULL THEN ''
      WHEN @sentence <> '' THEN
        @CRLF + 'Sentence: ' + @sentence
      ELSE ''
    END  

     SET @temp_offense = CASE
      WHEN @offense IS NULL THEN ''
      WHEN @offense <> '' THEN
        @CRLF
        + 'Offense: ' + lower(@offense)
        + @CRLF
        + 'Charge Type: ' + lower(@degree)
        + CASE
          WHEN @sentence IS NULL THEN ''
          WHEN @sentence <> '' THEN
            @CRLF + 'Sentence: ' + lower(@sentence)
          ELSE ''
        END  
      ELSE ''
    END  

    select @pub_notes = pub_notes from crim where crimid = @crim_id;
    if (@pub_notes <>'')
     begin
      set @pub_notes = 'Additional Items - ' + lower(@pub_notes);
     end

    UPDATE crim
      SET pub_notes = 'Order Status: ' + @temp_order_status
        + @CRLF
        + 'Result Status: ' + @temp_result_status
        + @temp_offense
        + @CRLF
        + 'Disposition: ' + lower(@disposition)
        + @CRLF
        + 'Disposition date: ' + cast(isnull(@disposed_on,' ') as varchar(11)) 
        + @CRLF
        + @pub_notes
      WHERE crimid = @crim_id;
   
END
