
CREATE PROCEDURE [dbo].[FormClientStatusCredentCheckSelect]
AS
	SET NOCOUNT ON;
--SELECT ClientStatusCredentCheckID, ClientName, 
--CLNO, Stage, Priority, NumberOfLicenses, Notes, GoLiveDate, RunTypeID, NumberTotal, NumberRemaining, DueDate, Contact, UpdatedOn, UpdatedBy, ClientStatusCredentClientParentID, HevnDataNotes, SendsHevn, SendsTerm, SendsNewHire, HEVN, CredentCheck, TradeRehire, PriorityTask, LastUpdated, NextEvent, AreLicensesMapped, AreJobTitleRequirementsSet, HEVNdataDate, LicenseDataNotes, NewHireDataDate, NewHireDataNotes, TermDataDate, TermDataNotes, LicenseDataDate FROM ClientStatusCredentCheck WHERE (UpdatedOn = (SELECT MAX(updatedon) FROM clientstatuscredentcheck C1 WHERE ClientStatusCredentcheck.ClientStatusCredentClientParentID = c1.ClientStatusCredentClientParentID))



exec hevn.dbo.UpcomingCredentialingRuns 13