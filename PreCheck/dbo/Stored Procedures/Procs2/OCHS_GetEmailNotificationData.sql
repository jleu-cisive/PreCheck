-- =============================================
-- Author:		Najma Begum
-- Create date: 05/29/2013
-- Description:	Get Email address for sending drugscreen email notification
-- Modified by Radhika Dereddy on 08/01/2019 for turning off Drug Testing Notificaiton for HCA by checking the configruation key.
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_GetEmailNotificationData]
	-- Add the parameters for the stored procedure here
	 @Apno int = 0, @CLNO int=0, @GenericEmail bit = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @RecepientEmailList varchar(max);
	SET @RecepientEmailList = '';
	declare @Email varchar(max);
	declare @HasConfig varchar(25)= 'False';
	--declare @ClientName varchar(max);
	declare @Id int;
	declare @DoesAttnExist table([RowNum] [int] IDENTITY (1, 1) NOT NULL,AttnExistsCount int);
	declare @TmpClientEmail table([RowNum] [int] IDENTITY (1, 1) NOT NULL,ClientEmail varchar(100));
	declare @CheckEmailFlag table([RowNum] [int] IDENTITY (1, 1) NOT NULL,RecepientEmail varchar(max));
	declare @GetEmails table([RowNum] [int] IDENTITY (1, 1) NOT NULL,RecepientEmail varchar(100));
	declare @FirstLastAutoEmailPdf table([RowNum] [int] IDENTITY (1, 1) NOT NULL, ApDate datetime, Attn varchar(25), ApStatus char(1), APNO int, CLNO int, UserID varchar(8), email varchar(100), [First] varchar(25), 
                      [Last] varchar(25),Middle varchar(25),DeliveryMethodID int, DeliveryMethod varchar(50), EmailAddress varchar(100), Expr1 varchar(25));

	declare @skipDrugTestingNotification varchar(25);

	if(@Apno is not null and @Apno > 0 and exists(select a.apno from appl a INNER JOIN dbo.OCHS_CandidateInfo C ON C.APNO = a.APNO WHERE a.apno = @Apno))
		BEGIN
			insert into @DoesAttnExist (AttnExistsCount) Exec [dbo].[Service_CheckAttnMatch] @Apno;
			--if(@Clno is null OR @Clno = 0 )
			select @Clno = clno from appl where apno = @Apno;
			select @HasConfig = isnull(value,'False') from clientconfiguration where clno = @clno and Configurationkey = 'WO_Merge_DrugScreeningRequired';

			select @skipDrugTestingNotification = isnull(value, 'False') from ClientConfiguration where clno =@clno and ConfigurationKey ='SkipDrugTestingNotification'

			--BEGIN: Radhika Dereddy on 08/01/2019 added the below logic to skip HCA HROC Drug Test notification				
				If(@skipDrugTestingNotification ='True')
				Begin		
					Set @HasConfig = 'True'
				End
				
			--END: Radhika Dereddy on 08/01/2019 added the below logic to skip HCA HROC Drug Test notification

			insert into  @GetEmails (RecepientEmail) Exec [dbo].[Service_CheckEmailFlag] @clno,'';

			while exists(Select * from @GetEmails)
			BEGIN
			select top 1 @Email = LTRIM(RTRIM(RecepientEmail)), @Id = RowNum from @GetEmails;
			SET @RecepientEmailList = @RecepientEmailList + @Email + ';';
			delete @GetEmails where RowNum = @Id;
			END
		
			insert into @CheckEmailFlag (RecepientEmail) values (@RecepientEmailList);
		
			insert into @FirstLastAutoEmailPdf (ApDate, Attn, ApStatus, APNO, CLNO , UserID, email, [First] , 
						  [Last],Middle,DeliveryMethodID, DeliveryMethod , EmailAddress, Expr1)
						  Exec [dbo].[Service_FirstLastAutoEmailPdf] @Apno ;
			if(@HasConfig = 'False' )
			BEGIN
			select  a.AttnExistsCount, c.RecepientEmail, /*f.email as clientemail,*/ f.userid as cam, u.name as camname, f.[first],f.[last],f.[middle],f.EmailAddress as CamEmail,f.Attn from @DoesAttnExist a inner join @CheckEmailFlag c on a.[rownum] = c.[rownum] inner join @FirstLastAutoEmailPdf f on c.[rownum] = f.[rownum] inner join dbo.Users u on u.userid = f.userid;

			END
		
		END
	ELSE
		BEGIN
			if(@Clno is not null and @Clno > 0)
			if ((select count(*) from @TmpClientEmail) > 0)
				delete from @TmpClientEmail;
			insert into @TmpClientEmail (ClientEmail) 
			select Email as clientemail from precheck_Staging.dbo.NotificationConfig where Clno = @Clno and refNotificationTypeId in (select refNotificationTypeID from precheck_Staging.dbo.refNotificationType where [Description] = 'DrugScreenNotification')

			--select a.AttnExistsCount, c.RecepientEmail, f.userid as cam, f.[first],f.[last],f.[middle],f.EmailAddress as CamEmail,f.Attn, ce.clientemail from @DoesAttnExist a inner join @CheckEmailFlag c on a.[rownum] = c.[rownum] inner join @FirstLastAutoEmailPdf f on c.[rownum] = f.[rownum] inner join @TmpClientEmail ce on f.[rownum] = ce.[rownum]; 
			select '' AttnExistsCount, clientemail as RecepientEmail, '' cam, '' [first],'' [last],'' [middle],'' CamEmail,'' Attn from @TmpClientEmail 
			SET @GenericEmail = 1;
		END
	
		
END
--NOTE: maybe add clno in return function??

