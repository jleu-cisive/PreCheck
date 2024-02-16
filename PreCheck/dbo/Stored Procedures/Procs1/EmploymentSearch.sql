
/*
Procedure Name : EmploymentModuleSearch
Requested By: Milton
Developer: Deepak Vodethela
Execution : 
	-- Apno - 1st Position
	EXEC EmploymentSearch 2541810 , '', '', '', '', '',''
	-- DOB - 2nd Position
	EXEC EmploymentSearch '', '08/18/1983', '', '', '', '', ''
	-- LastName - 3rd Position
	EXEC EmploymentSearch '', '', 'KEENER', '', '', '', ''
	-- FirstName - 4th Position
	EXEC EmploymentSearch '', '', '', 'Marsha', '', '',''
	-- Employer Name - 5th Position
	EXEC EmploymentSearch '', '', '', '', 'Forest Cove Baptist Church','',''
	-- VID Search - EmplID - 6th Position
	EXEC EmploymentSearch '', '', '', '', '',306975,''
	-- VID Search - Last 4 SSN Search - 7th Position
	EXEC EmploymentSearch '', '', '', '', '','','0078'
	-- All Parameters
	EXEC EmploymentSearch 2536745, '08/18/1983', 'Credeur', 'Jamie', 'Covenant Medical Center','',''

*/

CREATE PROCEDURE [dbo].[EmploymentSearch]
(
	/* Input Parameters */
	@Application INT = NULL,
	@Client NVarchar(100) = NULL,
	@LastName NVarchar(30) = NULL,
	@FirstName NVarchar(30) = NULL,
	@Employer NVarchar(30) = NULL,
	@EmplID	int = NULL,
	@Last4SSN NVarchar(11) = NULL
)
AS
SET NOCOUNT ON

	/* Variable Declaration */
	DECLARE @SQLQuery AS NVarchar(MAX)
	DECLARE @Where NVarchar(MAX)
	DECLARE @OrderBy NVarchar(100)

	/* Initiliaze Where and OrderBy clause*/
	SET @Where = ' WHERE 1 = 1 '  

	SET @OrderBy = ' ORDER BY A.ApDate DESC'

	/* Check for the condition and build the WHERE clause accordingly */
    If  ISNULL(@Application,'') != ''
         Set @Where = @Where + ' And A.Apno = ' + CONVERT(VARCHAR(20),@Application) + '' 

    If ISNULL(@LastName,'') != ''
         Set @Where = @Where + ' And A.Last = ''' + replace(@LastName,'''','''''') + ''''
  
    If ISNULL(@FirstName,'') != ''
         Set @Where = @Where + ' And A.First = ''' + replace(@FirstName,'''','''''') + ''''
  
    If ISNULL(@Employer,'') != ''
         Set @Where = @Where + ' And E.Employer like ''' + replace(@Employer,'''','''''') + '%'''

    If ISNULL(@Client,'') != ''
         Set @Where = @Where + ' And C.Name like ''' + replace(@Client,'''','''''') + '%'''

    If ISNULL(@EmplID,'') != ''
         Set @Where = @Where + ' And E.EmplID = ''' + CONVERT(VARCHAR(20),@EmplID) + ''''

    If ISNULL(@Last4SSN,'') != ''
         Set @Where = @Where + ' And RIGHT(A.SSN,4) = ''' + @Last4SSN + ''''

	--/* Build the Transact-SQL String with the input parameters */ 
	--Set @SQLQuery = 'SELECT TOP 100 A.APNO, A.DOB, A.ssn , A.ApDate, A.ApStatus, A.First, A.Last, E.EmplID, E.Employer, E.SectStat, E.Investigator, A.CLNO, C.Name, 
	--						ref.Affiliate, E.zipcode,E.State, E.City , dbo.fnGetTimeZone(E.zipcode,E.city,E.State) TimeZone  
	--				FROM dbo.Appl AS A WITH(NOLOCK)  
	--				INNER JOIN dbo.Empl AS E WITH(NOLOCK) ON E.APNO = A.APNO  
	--				INNER JOIN dbo.Client AS C WITH(NOLOCK) ON A.CLNO = C.CLNO  
	--				INNER JOIN dbo.refAffiliate AS ref WITH(NOLOCK) ON C.AffiliateID = ref.AffiliateID ' + @Where + @OrderBy

	Set @SQLQuery = 'SELECT TOP 50 A.APNO, A.SSN, A.ApDate, E.EmplID, E.Employer, A.ApStatus, E.State, E.City, E.web_status, E.web_updated, E.Investigator  
							,A.First, A.Last, A.PrecheckChallenge, A.Rush, C.HighProfile, A.CLNO, C.Name, E.EmplID, ref.Affiliate,  IsNull(C.OkToContact,0) as oktocontact  
							,CASE  WHEN A.special_instructions IS NULL THEN ''No'' ELSE ''Yes'' END AS ''SI'',E.DateOrdered,E.OrderId, E.Zipcode, MainDB.dbo.fnGetTimeZone(E.zipcode,E.city,E.State) TimeZone   
					  FROM dbo.Appl A WITH(NOLOCK)  
					  INNER JOIN dbo.Empl E ON A.APNO = E.APNO  
					  INNER JOIN dbo.Client C ON A.CLNO = C.CLNO  
					  INNER JOIN dbo.refAffiliate ref ON C.AffiliateID = ref.AffiliateID ' + @Where + @OrderBy


	/* Execute the t-Sql*/
	EXEC (@SQLQuery) 

	--PRINT (@SQLQuery)

