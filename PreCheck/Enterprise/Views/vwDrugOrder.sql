





CREATE VIEW [Enterprise].[vwDrugOrder]
AS
SELECT 
	CandidateId=ci.CandidateId,
	OrderNumber = a.APNO,
	ClientId=CONVERT(INT,a.CLNO),
	LastName=a.Last,
	FirstName=a.First,
	Middle=a.Middle,
	SSN=A.SSN,
	DOB=CONVERT(DATE,a.DOB),
	Address1=CI.Address1,
	CI.Address2,
	City=CI.City,
	[State]=a.State,
	Zip=a.Zip,
	Email=a.Email,
	a.Phone,
	ci.TestReason,
	ci.CreatedDate,
	ci.ScreeningType,
	ci.OrderStatus,
	ci.TestResult,
	ci.TestResultDate,
	ci.CoC,
	ci.LastUpdate,
	ci.ReasonForTest,
	IsActive=ISNULL(ci.IsActive,1),
	ci.TID
FROM Appl a WITH (NOLOCK)
INNER JOIN [dbo].[vwDrugResultCurrent] ci WITH (NOLOCK)
	ON a.APNO=ci.APNO









