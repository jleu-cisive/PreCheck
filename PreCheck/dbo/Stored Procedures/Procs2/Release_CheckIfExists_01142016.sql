



-- =============================================

-- Author:		sChapyala

-- Create date: 11/05/2010

-- Description:	Returns SSN,DOB on the release if a release is found 

--				for the applicant based on SSN, I94 or ClientApplication Number (Unique Client identifier)

-- =============================================

-- =============================================

-- Author:		sChapyala

-- Modified date: 09/10/2013

-- Description:	Changed the SP to search by SSN first, ClientApp number next and then by I94

-- =============================================

-- =============================================

-- Author:		sChapyala

-- Modified date: 09/17/2013

-- Description:	Changed the SP to search by  ClientApp number first and then by SSN or I94

--              Also added the ParentCLNO logic if release sharing is setup - Hierarchy

--Modified by schapyala on 09/01/2015

--Lookup CandidateID and other client reference numbers that are available in some integrations like Kenexa

-- =============================================

/*

[dbo].[Release_CheckIfExists] 7519,'1943473','458-89-8741',0



exec [dbo].[Release_CheckIfExists] 3035,'1010700TEST','',0



[dbo].[Release_CheckIfExists] 5751,'24','',1

*/

CREATE PROCEDURE [dbo].[Release_CheckIfExists_01142016]

	@CLNO Int,

	@ClientAppNo Varchar(50)='',

	@SSN varchar(20)='',

	@IncludePDF bit =0 

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	
	CREATE TABLE #tmpclients
	(CLNO Int)

	CREATE TABLE dbo.#tmpRelease

	(SSN Varchar(50),

	DOB Date,

	Report Image,

	RecruiterEmail varchar(100),

	ReleaseDate DateTime
	)



--Modified by schapyala on 01/28/14 to create a child to child, child to parent relationship to find the release



--Declare @ParentCLNO int



--Select @ParentCLNO =  ParentCLNO

--from [dbo].[ClientHierarchyByService] Where CLNO = @CLNO and [refHierarchyServiceID] = 2



--Set @ParentCLNO = Isnull(@ParentCLNO,@CLNO)


IF @CLNO = 7519 
	Insert into #tmpclients
	Select distinct FacilityCLNO From HEVN..Facility Where ParentEmployerID = @CLNO and FacilityCLNO is not null
else
	Insert into #tmpclients
	Select clno from DBO.ClientHierarchyByService (NoLock)

	where parentclno in (select parentclno from Dbo.ClientHierarchyByService  (NoLock)

														where (clno = @CLNO or parentclno = @CLNO) and refHierarchyServiceID=2 )



--End modification 01/28....the where clause is also changed below

--Include the CLNO passed as well
Insert into #tmpclients
Select @CLNO


IF isnull(@ClientAppNo,'')<>''

BEGIN

		Insert dbo.#tmpRelease

		SELECT TOP 1 ISNULL(rf.SSN,rf.I94) as SSN,rf.DOB,(case when @IncludePDF = 1 then pdf else null end) Report,null as RecruiterEmail,rf.[Date] ReleaseDate

		FROM   DBO.ReleaseForm rf  (NoLock)

		--WHERE (rf.CLNO = @CLNO OR rf.CLNO = @ParentCLNO)

		WHERE (rf.CLNO = @CLNO OR rf.CLNO in (Select clno From #tmpclients)) --Modified by schapyala on 01/28/14

		AND    ClientAppNo = @ClientAppNo 

		AND   [date] > DateAdd(d,-90,current_timestamp)

		ORDER BY [Date] desc


		--If ClientAppNo does not match, pull the candidateID from transformmedrequest and then try with that. Mostly applies for Kenexa and other similar integrations where they have multiple reference numbers
		--schapyala 09/01/2015
		IF (Select count(1) from dbo.#tmpRelease) <=0
		BEGIN
			Declare @CandidateID varchar(50)

			SELECT @CandidateID = cast( NewTable.RequestXML.query('data(CandidateID)')  as varchar)

			From dbo.Integration_OrderMgmt_Request CROSS APPLY TransformedRequest.nodes('//Application/NewApplicant') AS NewTable(RequestXML) 

			Where (CLNO = @CLNO OR FacilityCLNO = @CLNO)

			AND   Partner_Reference = @ClientAppNo

			--Lookup using the CandidateID
			If Isnull(@CandidateID,'')<>''
				Insert dbo.#tmpRelease

				SELECT TOP 1 ISNULL(rf.SSN,rf.I94) as SSN,rf.DOB,(case when @IncludePDF = 1 then pdf else null end) Report,null as RecruiterEmail,rf.[Date] ReleaseDate

				FROM   DBO.ReleaseForm rf  (NoLock)

				--WHERE (rf.CLNO = @CLNO OR rf.CLNO = @ParentCLNO)

				WHERE (rf.CLNO = @CLNO OR rf.CLNO in (Select clno From #tmpclients)) --Modified by schapyala on 01/28/14

				AND    ClientAppNo = @CandidateID 

				AND   [date] > DateAdd(d,-90,current_timestamp)

				ORDER BY [Date] desc

		END
END



IF isnull(@SSN,'')<>''

BEGIN

	IF (select count(1) from dbo.#tmpRelease)=0

		Insert dbo.#tmpRelease

		SELECT TOP 1 ISNULL(rf.SSN,rf.I94) as SSN,rf.DOB,(case when @IncludePDF = 1 then pdf else null end) Report,null as RecruiterEmail,rf.[Date] ReleaseDate 

		FROM   DBO.ReleaseForm rf  (NoLock)

		--WHERE (rf.CLNO = @CLNO OR rf.CLNO = @ParentCLNO)

		WHERE (rf.CLNO = @CLNO OR rf.CLNO in (Select clno From #tmpclients))  --Modified by schapyala on 01/28/14

		AND replace(rf.SSN,'-','') = replace(@SSN,'-','') or rf.I94 = @SSN -- Modified by ddegenaro on 01/30/14
		--AND    rf.SSN = @SSN or rf.I94 = @SSN

		AND   [date] > DateAdd(d,-90,current_timestamp)

		ORDER BY [Date] desc



END



SELECT * FROM dbo.#tmpRelease



DROP TABLE dbo.#tmpclients

DROP TABLE dbo.#tmpRelease



END


