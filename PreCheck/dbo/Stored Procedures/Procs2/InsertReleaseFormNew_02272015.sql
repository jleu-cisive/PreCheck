
/*
EXEC [dbo].[InsertReleaseFormNew_02272015] NULL, '204-66-9510', NULL, 'Jenna', 'Enderle',6790, NULL, '11/26/1986', NULL

SELECT * FROM ReleaseForm where ReleaseFormID = 1850656
*/

CREATE PROCEDURE [dbo].[InsertReleaseFormNew_02272015]
    @pdf AS IMAGE,
    @ssn AS VARCHAR (11),
    @i94 AS VARCHAR (50) = null,
    @first AS VARCHAR (50),
    @last AS VARCHAR (50),
	@CLNO as INT,
	@EnteredVia as VARCHAR (15)=null,
	@DOB as DATETIME =null,				--Added by Radhika Dereddy on 06/12/2015
	--@DOB as VARCHAR(30) =null,		--Added by Radhika Dereddy on 09/26/2013, commented 11/01/2016
	@ApplicantInfopdf AS IMAGE,			--Added by Radhika Dereddy on 09/26/2013
	@id int OUTPUT			--Added by Radhika Dereddy on 10/01/2013
AS

--Commented by Radhika Dereddy on 09/26/2013
--INSERT INTO ReleaseForm (PDF,ssn,i94,first,last,clno,EnteredVia)
--VALUES ( @PDF,@SSN,@i94,@first,@last,@CLNO,@EnteredVia)

--IF(@DOB IS NOT NULL)
--	BEGIN
--		 SET @DOB = CAST(@DOB AS datetime)
--	END

	--Added DOB and applicantInfoPdf parameters for Studentcheck 04/22/2014
	INSERT INTO ReleaseForm (PDF,ssn,i94,first,last,clno,EnteredVia,DOB,applicantinfo_pdf)
	VALUES (@PDF,@SSN,@i94,@first,@last,@CLNO,@EnteredVia,@DOB,@ApplicantInfopdf)

	--SELECT @id = SCOPE_IDENTITY() 
	SET @id = SCOPE_IDENTITY()
	SELECT @id