
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--[OCHS_GetResults_BasedOnSearchCriteria] '','','HighTower','',0
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_GetResults_BasedOnSearchCriteria] --'','','','d''nico',1
	@SSN varchar(20) ='',
	@Apno varchar(50)='',
	@LastName varchar(50),
	@FirstName varchar(50),
	@CLNO INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    if(@SSN <>'' and @Apno ='' and @LastName ='' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName ='' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName <>'' and @FirstName ='' and (@CLNO ='' or @CLNO=0))
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName ='' and @FirstName ='' and (@CLNO <>'' or @CLNO = 0))
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.CLNO = @CLNO order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName ='' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.OrderIDOrApno = @Apno order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName ='' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.CLNO = @CLNO order by TID desc;
    else if(@SSN ='' and @Apno <>'' and @LastName <>'' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName ='' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName ='' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.FirstName like '%'+@FirstName+'%' and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName <>'' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.LastName like '%'+@LastName+'%' and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.FirstName like '%'+@FirstName+'%' and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName <>'' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.OrderIDOrApno = @Apno and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName ='' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName ='' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.OrderIDOrApno = @Apno and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.LastName like '%'+@LastName+'%' and rd.FirstName = @FirstName order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.LastName like '%'+@LastName+'%' and rd.FirstName = @FirstName order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.LastName like '%'+@LastName+'%' and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.FirstName like '%'+@FirstName+'%' and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.LastName like '%'+@LastName+'%' and rd.FirstName=@FirstName order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName ='' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' and rd.CLNO=@CLNO order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.LastName like '%'+@LastName+'%' and rd.FirstName like '%'+@FirstName+'%' and rd.CLNO=@CLNO order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID=@SSN and rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.SSNOrOtherID=@SSN and rd.CLNO=@CLNO and rd.FirstName like '%'+@FirstName+'%' and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName <>'' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd left join client c on rd.clno = c.clno where rd.CLNO = @CLNO and rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' and rd.LastName like '%'+@LastName+'%' order by TID desc;
END

