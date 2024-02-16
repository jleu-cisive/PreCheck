-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 8/9/2018
-- Description:	Function returns list of applicant names from past 5 years for a given client
-- =============================================
CREATE FUNCTION [dbo].[fnGetClinicApplicantsNames]
(
	-- Add the parameters for the function here
	@clinicClientId int
)
RETURNS 
@Applicants TABLE 
(
	FirstName	VARCHAR(100),
	LastName	VARCHAR(100),
	ClientId	INT,
	ClinicId	INT
)
AS
BEGIN
	INSERT INTO @Applicants
	        ( FirstName, LastName, ClientId, ClinicId )
	SELECT DISTINCT
	FirstName=[First],
	LastName=[Last],
	ClientId=[CLNO],
	ClinicId=asa.CLNO_Hospital
	FROM dbo.Appl a
		JOIN ApplStudentAction asa
		ON a.APNO = asa.APNO
	WHERE a.CreatedDate >=DATEADD(YEAR,-5,GETDATE())
	AND asa.CLNO_Hospital=@clinicClientId
	AND ISNULL(asa.IsActive,1)=1
	RETURN 
END
