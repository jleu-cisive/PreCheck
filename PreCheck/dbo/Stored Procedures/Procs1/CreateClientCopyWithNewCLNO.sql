CREATE PROCEDURE CreateClientCopyWithNewCLNO
@CLNO smallint,
@Name varchar(100)

AS
declare
@newclno smallint

--add client info
insert into client ( [Name], [Addr1], [Addr2], [Addr3], [City], [State], [Zip], [Phone], [Fax], [Contact], [Email], [HomeCounty], [TaxRate], [Status], [BillCycle], [LastInvDate], [LastInvAmount], [CNTY_NO], [AffiliateID], [TeamID], [CountyCrimID], [CountyCrimNotesID], [StateCrimNotesID], [Social], [MVR], [Medicaid/Medicare], [EmploymentID], [EmploymentNotes1ID], [EmploymentNotes2ID], [EducationNotesID], [LicenseNotesID], [CreditNotesID], [PersonalRefNotes], [Comments], [DeliveryMethodID], [BillingCycleID], [BillingStatusID], [AttnTo], [BillingAddress1], [BillingAddress2], [BillingCity], [BillingState], [BillingZip], [PrintLabel], [TaxStatusID], [TaxRateID], [SalesPersonUserID], [CustomerRatingID], [HolidayGift], [password], [HEVNEmployer], [ParentCLNO], [CompanyLogoPath], [NonClient], [DescriptiveName], [Medical])
SELECT @name, [Addr1], [Addr2], [Addr3], [City], [State], [Zip], [Phone], [Fax], [Contact], [Email], [HomeCounty], [TaxRate], [Status], [BillCycle], [LastInvDate], [LastInvAmount], [CNTY_NO], [AffiliateID], [TeamID], [CountyCrimID], [CountyCrimNotesID], [StateCrimNotesID], [Social], [MVR], [Medicaid/Medicare], [EmploymentID], [EmploymentNotes1ID], [EmploymentNotes2ID], [EducationNotesID], [LicenseNotesID], [CreditNotesID], [PersonalRefNotes], [Comments], [DeliveryMethodID], [BillingCycleID], [BillingStatusID], [AttnTo], [BillingAddress1], [BillingAddress2], [BillingCity], [BillingState], [BillingZip], [PrintLabel], [TaxStatusID], [TaxRateID], [SalesPersonUserID], [CustomerRatingID], [HolidayGift], [password], [HEVNEmployer], [ParentCLNO], [CompanyLogoPath], [NonClient], [DescriptiveName], [Medical]
FROM [precheck].[dbo].[Client]
where clno = @clno

--get new client number
select @newclno = clno
from client
where name = @name

--add client contacts
insert into clientcontacts ([CLNO], [PrimaryContact], [ContactType], [ContactTypeID], [ReportFlag], [Title], [FirstName], [MiddleName], [LastName], [Phone], [Ext], [Email], [tmpPhone], [username], [UserPassword])
select @newclno, [PrimaryContact], [ContactType], [ContactTypeID], [ReportFlag], [Title], [FirstName], [MiddleName], [LastName], [Phone], [Ext], [Email], [tmpPhone], [username], [UserPassword]
FROM [Precheck].[dbo].[ClientContacts]
where clno = @clno

--add clientcrimrate
insert into clientcrimrate ([CLNO], [County], [Rate], [CNTY_NO], [ExcludeFromRules])
select @newclno, [County], [Rate], [CNTY_NO], [ExcludeFromRules]
FROM [Precheck].[dbo].[ClientCrimRate]
where clno = @clno

--add clientnotes
insert into clientnotes ([CLNO], [NoteType], [NoteBy], [NoteDate], [NoteText])
select @newclno, [NoteType], [NoteBy], [NoteDate], [NoteText]
FROM [Precheck].[dbo].[ClientNotes]
where clno = @clno

--add clientpackages
insert into clientpackages ([CLNO], [PackageID], [Rate])
select @newclno, [PackageID], [Rate]
FROM [Precheck].[dbo].[ClientPackages]
where clno = @clno

--add clientrates
insert into clientrates ([CLNO], [RateType], [ServiceID], [Rate])
select @newclno, [RateType], [ServiceID], [Rate]
FROM [Precheck].[dbo].[ClientRates]
where clno = @clno

--add weborderprefs
insert into weborderprefs ([Clno], [Fax], [callfax], [faxoremail], [Email], [criminalbackground], [socialsecurity], [medicaid], [motorvehicle], [personalreferences], [licenseverification], [education], [employment], [creditreport], [PreferenceCounty1], [PreferenceCounty2], [PreferenceState1], [PreferenceState2], [PreferenceStatewide], [OtherAreas], [Service900], [homehealth], [childcare], [socialworker], [mentalhealth], [teacher], [skillednursing], [Rehabilitation], [Longtermcare])
select @newclno, [Fax], [callfax], [faxoremail], [Email], [criminalbackground], [socialsecurity], [medicaid], [motorvehicle], [personalreferences], [licenseverification], [education], [employment], [creditreport], [PreferenceCounty1], [PreferenceCounty2], [PreferenceState1], [PreferenceState2], [PreferenceStatewide], [OtherAreas], [Service900], [homehealth], [childcare], [socialworker], [mentalhealth], [teacher], [skillednursing], [Rehabilitation], [Longtermcare]
FROM [Precheck].[dbo].[WeborderPrefs]
where clno = @clno