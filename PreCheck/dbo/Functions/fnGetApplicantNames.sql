-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 8/9/2018
-- Description:	Function returns list of applicant names from past 5 years for a given client
-- =============================================
CREATE FUNCTION [dbo].[fnGetApplicantNames]
(
	-- Add the parameters for the function here
	@clientId int
)
RETURNS 
@Applicants TABLE 
(
	FirstName VARCHAR(100),
	LastName VARCHAR(100),
	ClientId	 int
)
AS
BEGIN
	
	INSERT INTO @Applicants
	        ( FirstName, LastName, ClientId )
			/*
	SELECT DISTINCT
	 FirstName=[First],
	LastName=[Last],
	ClientId=[CLNO]
	FROM dbo.Appl a
	WHERE a.CreatedDate >=DATEADD(YEAR,-5,GETDATE())
	AND CLNO=@clientId
	*/
	SELECT 
	--DISTINCT
	 FirstName=[First],
	LastName=[Last],
	ClientId=[CLNO]
	FROM MainDB.dbo.Sch_Client_Candidate  WITH (SNAPSHOT)

	WHERE CLNO=@clientId
	RETURN 
END
