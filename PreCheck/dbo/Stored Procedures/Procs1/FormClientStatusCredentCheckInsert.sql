CREATE PROCEDURE dbo.FormClientStatusCredentCheckInsert
(
	@ClientName varchar(100),
	@CLNO int,
	@Stage int,
	@Priority int,
	@NumberOfLicenses int,
	@Notes varchar(200),
	@GoLiveDate datetime,
	@RunTypeID varchar(50),
	@NumberTotal int,
	@NumberRemaining int,
	@DueDate datetime,
	@Contact varchar(50),
	@UpdatedOn datetime,
	@UpdatedBy varchar(50),
	@ClientStatusCredentClientParentID int,
	@HevnDataNotes varchar(500),
	@SendsHevn bit,
	@SendsTerm bit,
	@SendsNewHire bit,
	@HEVN bit,
	@CredentCheck bit,
	@TradeRehire bit,
	@PriorityTask varchar(100),
	@LastUpdated datetime,
	@NextEvent varchar(50),
	@AreLicensesMapped bit,
	@AreJobTitleRequirementsSet bit,
	@HEVNdataDate datetime,
	@LicenseDataNotes varchar(100),
	@NewHireDataDate datetime,
	@NewHireDataNotes varchar(50),
	@TermDataDate datetime,
	@TermDataNotes varchar(50),
	@LicenseDataDate datetime,
	@HevnYears int
)
AS
	SET NOCOUNT OFF;
INSERT INTO ClientStatusCredentCheck(ClientName, CLNO, Stage, Priority, NumberOfLicenses, Notes, GoLiveDate, RunTypeID, NumberTotal, NumberRemaining, DueDate, Contact, UpdatedOn, UpdatedBy, ClientStatusCredentClientParentID, HevnDataNotes, SendsHevn, SendsTerm, SendsNewHire, HEVN, CredentCheck, TradeRehire, PriorityTask, LastUpdated, NextEvent, AreLicensesMapped, AreJobTitleRequirementsSet, HEVNdataDate, LicenseDataNotes, NewHireDataDate, NewHireDataNotes, TermDataDate, TermDataNotes, LicenseDataDate, HevnYears) VALUES (@ClientName, @CLNO, @Stage, @Priority, @NumberOfLicenses, @Notes, @GoLiveDate, @RunTypeID, @NumberTotal, @NumberRemaining, @DueDate, @Contact, @UpdatedOn, @UpdatedBy, @ClientStatusCredentClientParentID, @HevnDataNotes, @SendsHevn, @SendsTerm, @SendsNewHire, @HEVN, @CredentCheck, @TradeRehire, @PriorityTask, @LastUpdated, @NextEvent, @AreLicensesMapped, @AreJobTitleRequirementsSet, @HEVNdataDate, @LicenseDataNotes, @NewHireDataDate, @NewHireDataNotes, @TermDataDate, @TermDataNotes, @LicenseDataDate, @HevnYears);
	SELECT ClientStatusCredentCheckID, ClientName, CLNO, Stage, Priority, NumberOfLicenses, Notes, GoLiveDate, RunTypeID, NumberTotal, NumberRemaining, DueDate, Contact, UpdatedOn, UpdatedBy, ClientStatusCredentClientParentID, HevnDataNotes, SendsHevn, SendsTerm, SendsNewHire, HEVN, CredentCheck, TradeRehire, PriorityTask, LastUpdated, NextEvent, AreLicensesMapped, AreJobTitleRequirementsSet, HEVNdataDate, LicenseDataNotes, NewHireDataDate, NewHireDataNotes, TermDataDate, TermDataNotes, LicenseDataDate, HevnYears FROM ClientStatusCredentCheck WHERE (ClientStatusCredentCheckID = @@IDENTITY)


update clientstatuscredentcheck
set clientstatuscredentclientparentid = @@identity
where clientstatuscredentcheckid = @@identity