
CREATE PROCEDURE [dbo].[Integration_Verification_TALX_Run_Note] 
	@EmplID INT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Priv_Note VARCHAR(155)
	DECLARE @APNO INT

	SELECT @APNO = e.APNO
	FROM dbo.Empl e
	WHERE e.EmplID = @EmplID

	-- if talx was received
	UPDATE e 
	SET e.Priv_Notes = 'The work number has been ran for this SSN on a separate report. Please see documents. [TALXOrdered:null]' + CHAR(10)+CHAR(13) + e.Priv_Notes
	-- SELECT *
	FROM dbo.Empl e
	WHERE e.APNO = @APNO
	AND e.Investigator = 'TALX'
	AND e.EmplID IN (SELECT fl.EmplID FROM dbo.EmployerFuzzyNameMatching_Log fl WHERE fl.APNO = @APNO) 


	-- if talx was ran but NOT Received
	IF EXISTS(SELECT 1 FROM dbo.Integration_Verification_Transaction t WHERE t.apno = @APNO) -- IF TALX WAS RAN
	BEGIN
		UPDATE e 
		SET e.Priv_Notes = 'The work number has been ran for this SSN on a separate report. No Documents to attach. [TALXOrdered:null]' + CHAR(10)+CHAR(13) + e.Priv_Notes
		-- SELECT *
		FROM dbo.Empl e
		WHERE e.APNO = @APNO
		AND e.Investigator = 'TALX'
		AND e.EmplID NOT IN (SELECT fl.EmplID FROM dbo.EmployerFuzzyNameMatching_Log fl WHERE fl.APNO = @APNO)
	END

END
