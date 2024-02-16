
--Modify by JC 12/01/05 to add ClientType for StudentCheck
--Modified on 07/17/05 to handle PreAdverseLetterReturn and AdverseLetterReturn
--Modify By:	Joshua Ates
--Modify Date:	03/29/2021
--Modification:	Removed unnessisary transaction, moved Subquries in select statment to left join, made query easier to read
--EXEC [dbo].[sp_FormAdverseList] 5679262


CREATE PROC [dbo].[sp_FormAdverseList] @apno INT
AS


DECLARE @ErrorCode INT
	--,@apno INT 5679262

BEGIN TRY
	SELECT aa.AdverseActionID AS AAID
		,CASE a.apstatus
			WHEN 'f' THEN ''
			ELSE '*'
		 END AS [Not Finished]
		,aa.APNO
		,aa.StatusID
		,refas.STATUS 
		,CASE 
			WHEN aa.Hospital_CLNO IS NULL THEN ClientTypeIsNull.ClientType
			ELSE ClientTypeIsNotNull.ClientType
			END AS ClientType
		,aa.ClientEmail
		,aa.[Name] AS ApplicantName
		,aa.Address1
		,aa.Address2
		,aa.City
		,aa.STATE
		,aa.Zip
		,aa.PreAdverseLetterReturnID AS PALetterReturnID
		,x.refAdverseLetterReturnDesc AS PALetterReturnDesc
		,aa.AdverseLetterReturnID AS AALetterReturnID
		,y.refAdverseLetterReturnDesc AS AALetterReturnDesc
	FROM 
		AdverseAction aa WITH(NOLOCK)
	INNER JOIN
		refAdverseStatus refas WITH(NOLOCK)
		ON aa.StatusID = refas.refAdverseStatusID
	INNER JOIN
		Appl a WITH(NOLOCK)
		ON aa.apno = a.apno
	INNER JOIN
		refAdverseLetterReturn x WITH(NOLOCK)
		ON aa.PreAdverseLetterReturnID = x.refAdverseLetterReturnID
	INNER JOIN
		refAdverseLetterReturn y WITH(NOLOCK)
		ON aa.AdverseLetterReturnID = y.refAdverseLetterReturnID
	LEFT JOIN
		(
			SELECT CLNO, ClientType
			FROM Client WITH(NOLOCK)
			INNER JOIN refClientType 
			ON Client.ClientTypeID = refClientType.ClientTypeID
		)AS ClientTypeIsNull
		ON	a.clno = ClientTypeIsNull.clno
	LEFT JOIN
		(
			SELECT CLNO, ClientType
			FROM Client WITH(NOLOCK)
			INNER JOIN refClientType 
			ON Client.ClientTypeID = refClientType.ClientTypeID
		)AS ClientTypeIsNotNull
		ON	aa.Hospital_CLNO = ClientTypeIsNotNull.clno
	WHERE
		(aa.StatusID NOT IN (2,18,19,20))
		OR aa.apno = @apno
	ORDER BY aa.adverseactionid
END TRY
BEGIN CATCH
	RETURN (- @ErrorCode)
END CATCH


RETURN (0)
