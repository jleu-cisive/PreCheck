
CREATE PROCEDURE [dbo].[InsertReleaseFormNew]
    @pdf AS IMAGE,
    @ssn AS VARCHAR (11),
    @i94 AS VARCHAR (50) = null,
    @first AS VARCHAR (50),
    @last AS VARCHAR (50),
	@CLNO as INT,
	@EnteredVia as VARCHAR (15)=null
	--,
	--@DOB as DateTime,					--Added by Radhika Dereddy on 09/26/2013
	--@ApplicantInfopdf AS IMAGE,			--Added by Radhika Dereddy on 09/26/2013
	--@id int OUTPUT						--Added by Radhika Dereddy on 10/01/2013
AS

--Commented by Radhika Dereddy on 09/26/2013
INSERT INTO ReleaseForm (PDF,ssn,i94,first,last,clno,EnteredVia)
VALUES ( @PDF,@SSN,@i94,@first,@last,@CLNO,@EnteredVia)


--Added DOB and applicantInfoPdf parameters for Studentcheck 04/22/2014
--INSERT INTO ReleaseForm (PDF,ssn,i94,first,last,clno,EnteredVia,DOB,applicantinfo_pdf)
--VALUES (@PDF,@SSN,@i94,@first,@last,@CLNO,@EnteredVia,@DOB,@ApplicantInfopdf)

-- SET @id = SCOPE_IDENTITY()
-- SELECT @id