﻿
CREATE PROCEDURE dbo.FormClientStatusCredentCheckDelete
(
	@Original_ClientStatusCredentCheckID int,
	@Original_AreJobTitleRequirementsSet bit,
	@Original_AreLicensesMapped bit,
	@Original_CLNO int,
	@Original_ClientName varchar(100),
	@Original_ClientStatusCredentClientParentID int,
	@Original_Contact varchar(50),
	@Original_CredentCheck bit,
	@Original_DueDate datetime,
	@Original_GoLiveDate datetime,
	@Original_HEVN bit,
	@Original_HEVNdataDate datetime,
	@Original_HevnDataNotes varchar(500),
	@Original_LastUpdated datetime,
	@Original_LicenseDataDate datetime,
	@Original_LicenseDataNotes varchar(100),
	@Original_NewHireDataDate datetime,
	@Original_NewHireDataNotes varchar(50),
	@Original_NextEvent varchar(50),
	@Original_Notes varchar(200),
	@Original_NumberOfLicenses int,
	@Original_NumberRemaining int,
	@Original_NumberTotal int,
	@Original_Priority int,
	@Original_PriorityTask varchar(100),
	@Original_RunTypeID varchar(50),
	@Original_SendsHevn bit,
	@Original_SendsNewHire bit,
	@Original_SendsTerm bit,
	@Original_Stage int,
	@Original_TermDataDate datetime,
	@Original_TermDataNotes varchar(50),
	@Original_TradeRehire bit,
	@Original_UpdatedBy varchar(50),
	@Original_UpdatedOn datetime
)
AS
	SET NOCOUNT OFF;
DELETE FROM ClientStatusCredentCheck WHERE (ClientStatusCredentCheckID = @Original_ClientStatusCredentCheckID) 
--DELETE FROM ClientStatusCredentCheck WHERE (ClientStatusCredentCheckID = @Original_ClientStatusCredentCheckID) AND (AreJobTitleRequirementsSet = @Original_AreJobTitleRequirementsSet) AND (AreLicensesMapped = @Original_AreLicensesMapped) AND (CLNO = @Original_CLNO OR @Original_CLNO IS NULL AND CLNO IS NULL) AND (ClientName = @Original_ClientName OR @Original_ClientName IS NULL AND ClientName IS NULL) AND (ClientStatusCredentClientParentID = @Original_ClientStatusCredentClientParentID OR @Original_ClientStatusCredentClientParentID IS NULL AND ClientStatusCredentClientParentID IS NULL) AND (Contact = @Original_Contact OR @Original_Contact IS NULL AND Contact IS NULL) AND (CredentCheck = @Original_CredentCheck) AND (DueDate = @Original_DueDate OR @Original_DueDate IS NULL AND DueDate IS NULL) AND (GoLiveDate = @Original_GoLiveDate OR @Original_GoLiveDate IS NULL AND GoLiveDate IS NULL) AND (HEVN = @Original_HEVN) AND (HEVNdataDate = @Original_HEVNdataDate OR @Original_HEVNdataDate IS NULL AND HEVNdataDate IS NULL) AND (HevnDataNotes = @Original_HevnDataNotes OR @Original_HevnDataNotes IS NULL AND HevnDataNotes IS NULL) AND (LastUpdated = @Original_LastUpdated OR @Original_LastUpdated IS NULL AND LastUpdated IS NULL) AND (LicenseDataDate = @Original_LicenseDataDate OR @Original_LicenseDataDate IS NULL AND LicenseDataDate IS NULL) AND (LicenseDataNotes = @Original_LicenseDataNotes OR @Original_LicenseDataNotes IS NULL AND LicenseDataNotes IS NULL) AND (NewHireDataDate = @Original_NewHireDataDate OR @Original_NewHireDataDate IS NULL AND NewHireDataDate IS NULL) AND (NewHireDataNotes = @Original_NewHireDataNotes OR @Original_NewHireDataNotes IS NULL AND NewHireDataNotes IS NULL) AND (NextEvent = @Original_NextEvent OR @Original_NextEvent IS NULL AND NextEvent IS NULL) AND (Notes = @Original_Notes OR @Original_Notes IS NULL AND Notes IS NULL) AND (NumberOfLicenses = @Original_NumberOfLicenses OR @Original_NumberOfLicenses IS NULL AND NumberOfLicenses IS NULL) AND (NumberRemaining = @Original_NumberRemaining OR @Original_NumberRemaining IS NULL AND NumberRemaining IS NULL) AND (NumberTotal = @Original_NumberTotal OR @Original_NumberTotal IS NULL AND NumberTotal IS NULL) AND (Priority = @Original_Priority OR @Original_Priority IS NULL AND Priority IS NULL) AND (PriorityTask = @Original_PriorityTask OR @Original_PriorityTask IS NULL AND PriorityTask IS NULL) AND (RunTypeID = @Original_RunTypeID OR @Original_RunTypeID IS NULL AND RunTypeID IS NULL) AND (SendsHevn = @Original_SendsHevn OR @Original_SendsHevn IS NULL AND SendsHevn IS NULL) AND (SendsNewHire = @Original_SendsNewHire) AND (SendsTerm = @Original_SendsTerm) AND (Stage = @Original_Stage OR @Original_Stage IS NULL AND Stage IS NULL) AND (TermDataDate = @Original_TermDataDate OR @Original_TermDataDate IS NULL AND TermDataDate IS NULL) AND (TermDataNotes = @Original_TermDataNotes OR @Original_TermDataNotes IS NULL AND TermDataNotes IS NULL) AND (TradeRehire = @Original_TradeRehire) AND (UpdatedBy = @Original_UpdatedBy OR @Original_UpdatedBy IS NULL AND UpdatedBy IS NULL) AND (UpdatedOn = @Original_UpdatedOn OR @Original_UpdatedOn IS NULL AND UpdatedOn IS NULL)