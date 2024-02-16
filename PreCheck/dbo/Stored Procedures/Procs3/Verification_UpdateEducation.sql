--update appl set ssn = '222-22-2222',DOB='01/01/2001' where apno = 2188058

--select SchoolName,SchoolCode from NCHListwPrice

--dbo.Verification_UpdateEducation 1612087,2188058,'SchoolTest','03/20/06',@Studies='Studies',@ContactName='Test',@ContactTitie='Washer',@ContactDate=CURRENT_TIMESTAMP,2.50,'Bachelors','blah blah blah','blah blah',9,44,'DDegenar'

--select * from dbo.Educat where apno = 2188058

--insert into dbo.Educat(Apno,School,From_A,To_A) values (2188058,'Drew University','01/2001','01/2003')
--update dbo.Educat set School='DRAKE STATE TECHNICAL COLLEGE' where educatid = 1474342
-- updated on 3 feb 2023 by lalit for vendorcost

CREATE procedure [dbo].[Verification_UpdateEducation]

(@SectionId int,@apno int,@SchoolName varchar(50),@verifiedDateFrom varchar(12) = null,@verifiedDateTo varchar(12) = null,@Studies varchar(25) = null,@ContactName varchar(30),@ContactTitle varchar(100),@ContactDate DateTime,@BillingAmount smallmoney = null,@Degree

varchar(100) = null,@PrivateNotes varchar(max),@PublicNotes varchar(max),@SectStat char,@WebStatus int,@Investigator varchar(8),@IsSkipArchive bit = 0)

as

--declare @sectionId int

--declare @schoolName varchar(100)

declare @InvDetId int = 0

declare @Description varchar(max)


if (@sectionId is not null)
BEGIN

update

	dbo.Educat

set

	From_V = COALESCE(@verifiedDateFrom,FROM_V),

	To_V = @verifiedDateTo,

	Studies_V = @Studies,

	Contact_Name = @ContactName,

	Contact_Title = @ContactTitle,

	Contact_Date = @ContactDate,

	Degree_V = @Degree,

	Investigator = @Investigator,

	 Priv_Notes = isnull(@PrivateNotes,'') + char(10) + char(13) + isnull(cast(Priv_Notes as varchar(max)),''),

	Pub_Notes =  isnull(@PublicNotes,'') + char(10) + char(13) + isnull(cast(Pub_Notes as varchar(max)),''),

	SectStat = @SectStat,

	Web_Status = @webstatus

where

	EducatID = @sectionId
END
-- If we have a billing amount, update the billing table

if (IsNull(@BillingAmount,0) <> 0 and @IsSkipArchive = 1)

Begin

	--set @BillingAmount = @BillingAmount + 0.60
	--set @BillingAmount = @BillingAmount + 1.10
	set @BillingAmount = @BillingAmount + 1.00
	set @Description = 'SYSTEM:Education:NCH/' + @schoolName

	--exec dbo.CreateInvDetail @apno,1,null,null,@Description,@BillingAmount,@InvDetId
	 insert into InvDetail(Apno, Type, Subkey, SubkeyChar, CreateDate,Description, Amount)    
      values(@apno, 1, null,null, GETDATE(),@Description, @BillingAmount)
      SET @InvDetId = @@Identity
	exec [dbo].[updatethirdpartyinvreconEmEd] @sectionId,@apno,@schoolName,@BillingAmount,0,@InvDetId,@Description,2 ----- added by Lalit

End

select @InvDetId

--update dbo.Educat set School = 'DOWLING COLLEGE' where educatId = 1415950

