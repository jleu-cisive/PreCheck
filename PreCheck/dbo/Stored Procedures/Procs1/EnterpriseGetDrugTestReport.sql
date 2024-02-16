create   PROCEDURE dbo.[EnterpriseGetDrugTestReport] @tnCandidateIndfoID INT
AS
BEGIN
	SELECT  * FROM
	(
		(
		SELECT top 1 RD.TID, PDFReport,LastUpdate
		FROM OCHS_CandidateInfo CI with (nolock) JOIN OCHS_ResultDetails RD with (nolock) on CI.OCHS_CandidateInfoID = RD.OrderIDOrApno and RD.FirstName = CI.FirstName and RD.LastName = RD.LastName
											     LEFT OUTER JOIN OCHS_PDFReports DTR with  (nolock) on RD.TID = DTR.TID
		WHERE OCHS_CandidateInfoID = @tnCandidateIndfoID
		ORDER BY LastUpdate DESC
		)
		UNION
		(
		SELECT top 1 RD.TID, PDFReport, LastUpdate
		FROM OCHS_CandidateInfo CI with (nolock) JOIN OCHS_ResultDetails RD with (nolock) on CI.APNO = RD.OrderIDOrApno and RD.FirstName = CI.FirstName and RD.LastName = RD.LastName
			    							     LEFT OUTER JOIN OCHS_PDFReports DTR with  (nolock) on RD.TID = DTR.TID
		WHERE OCHS_CandidateInfoID = @tnCandidateIndfoID
		ORDER BY LastUpdate DESC
		)
	) t;

END

