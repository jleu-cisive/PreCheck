
CREATE PROCEDURE SetupClientMgmt_Client_tblRequirements AS

--Set **None** from flags
Update tblRequirements Set StateCrimNotes='**None**' WHERE StateCrim=0
Update tblRequirements Set CreditNotes='**None**' WHERE Credit=0
Update tblRequirements Set EducationNotes='**None**' WHERE Education=0
Update tblRequirements Set LicenseNotes='**None**' WHERE License=0
Update tblRequirements Set PersonalRefNotes='**None**' WHERE PersonalRef=0

--tblRequirements2Client
Update Client Set CountyCrimID=a.CountyCrimID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refCountyCrim a ON a.CountyCrim=ts.CountyCrim
Update Client Set CountyCrimNotesID=a.CountyCrimNotesID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refCountyCrimNotes a ON a.CountyCrimNotes=ts.CountyCrimNotes
Update Client Set StateCrimNotesID=a.StateCrimNotesID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refStateCrimNotes a ON a.StateCrimNotes=ts.StateCrimNotes
Update Client Set EducationNotesID=a.EducationNotesID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refEducationNotes a ON a.EducationNotes=ts.EducationNotes
Update Client Set LicenseNotesID=a.LicenseNotesID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refLicenseNotes a ON a.LicenseNotes=ts.LicenseNotes
Update Client Set CreditNotesID=a.CreditNotesID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refCreditNotes a ON a.CreditNotes=ts.CreditNotes
Update Client Set DeliveryMethodID=a.DeliveryMethodID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refDeliveryMethod a ON a.DeliveryMethod=ts.DeliveryMethod
Update Client Set EmploymentNotes1ID=a.EmploymentNotesID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refEmploymentNotes a ON a.EmploymentNotes=ts.EmploymentNotes1
Update Client Set EmploymentNotes2ID=a.EmploymentNotesID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refEmploymentNotes a ON a.EmploymentNotes=ts.EmploymentNotes2
Update Client Set EmploymentID=a.EmploymentID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements ts ON tc.ClientID=ts.ClientID
	JOIN refEmployment a ON a.Employment=ts.Employment

Update Client Set Social=tb.Social FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements tb ON tc.ClientID=tb.ClientID
Update Client Set MVR=tb.MVR FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements tb ON tc.ClientID=tb.ClientID
Update Client Set [Medicaid/Medicare]=tb.[Medicaid/Medicare] FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements tb ON tc.ClientID=tb.ClientID
Update Client Set PersonalRefNotes=tb.PersonalRefNotes FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements tb ON tc.ClientID=tb.ClientID
Update Client Set Comments=tb.Comments FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblRequirements tb ON tc.ClientID=tb.ClientID
