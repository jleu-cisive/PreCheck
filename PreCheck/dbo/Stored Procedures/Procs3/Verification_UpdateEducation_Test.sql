--update appl set ssn = '222-22-2222',DOB='01/01/2001' where apno = 2188058

--select SchoolName,SchoolCode from NCHListwPrice

--[dbo].[Verification_UpdateEducation_Test] 1612087,2188058,'SchoolTest','03/20/06',@Studies='Studies',@ContactName='Test',@ContactTitie='Washer',@ContactDate=CURRENT_TIMESTAMP,2.50,'Bachelors','blah blah blah','blah blah',9,44,'DDegenar'

--select * from dbo.Educat where apno = 2188058

--insert into dbo.Educat(Apno,School,From_A,To_A) values (2188058,'Drew University','01/2001','01/2003')
--update dbo.Educat set School='DRAKE STATE TECHNICAL COLLEGE' where educatid = 1474342

CREATE procedure [dbo].[Verification_UpdateEducation_Test]

(@SectionId int,@apno int,@SchoolName varchar(50),@verifiedDateFrom varchar(12) = null,@verifiedDateTo varchar(12) = null,@Studies varchar(25) = null,@ContactName varchar(30),@ContactTitle varchar(100),@ContactDate DateTime,@BillingAmount smallmoney = null,@Degree

varchar(100) = null,@PrivateNotes varchar(max),@PublicNotes varchar(max),@SectStat char,@WebStatus int,@Investigator varchar(8),@IsSkipArchive bit = 0)

as

--declare @sectionId int

--declare @schoolName varchar(100)

declare @InvDetId int = 0

declare @Description varchar(max)
declare @ProcessingFee smallmoney = null


if (IsNull(@BillingAmount,0) <> 0 and @IsSkipArchive = 1)

Begin

	select top 1 @ProcessingFee = Value from dbo.ClientConfiguration where ConfigurationKey='NSCProcessingFee'
	set @BillingAmount = @BillingAmount + IsNull(@ProcessingFee,0)
	set @Description = 'SYSTEM:Education:NCH/' + @schoolName

	--exec dbo.CreateInvDetail @apno,1,null,null,@Description,@BillingAmount,@InvDetId

End

select @BillingAmount,@Description

--update dbo.Educat set School = 'DOWLING COLLEGE' where educatId = 1415950

