
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--Exec [dbo].[OCHS_GetResults_BasedOnSearchCriteria_WithSSN] '','','Hightower','',0
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_GetResults_BasedOnSearchCriteria_WithSSN] 
	@SSN varchar(20),
	@Apno varchar(50),
	@LastName varchar(50),
	@FirstName varchar(50),
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    if(@SSN <>'' and @Apno ='' and @LastName ='' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID like '%@SSN%' order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName ='' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName <>'' and @FirstName ='' and (@CLNO ='' or @CLNO =0))
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO = '')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.FirstName like '%'+@FirstName+'%' order by TID desc;
    else if(@SSN ='' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO = 0)
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.FirstName like '%'+@FirstName+'%' and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName ='' and @FirstName ='' and (@CLNO <>'' or @CLNO = 0))
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.CLNO = @CLNO order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName ='' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.OrderIDOrApno = @Apno order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName ='' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.CLNO = @CLNO order by TID desc;
    else if(@SSN ='' and @Apno <>'' and @LastName <>'' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName ='' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName ='' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.FirstName like '%'+@FirstName+'%' and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName <>'' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.LastName = @LastName and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN ='' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.FirstName like '%'+@FirstName+'%' and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName <>'' and @FirstName ='' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.OrderIDOrApno = @Apno and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName ='' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName ='' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.OrderIDOrApno = @Apno and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.LastName like '%'+@LastName+'%' and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.LastName like '%'+@LastName+'%' and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName ='' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.LastName like '%'+@LastName+'%' and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName ='' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID = @SSN and rd.FirstName like '%'+@FirstName+'%' and rd.CLNO = @CLNO order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.LastName like '%'+@LastName+'%' and rd.FirstName like '%'+@FirstName+'%' order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName ='' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' and rd.CLNO=@CLNO order by TID desc;
	else if(@SSN ='' and @Apno = '' and @LastName <>'' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.LastName = @LastName and rd.FirstName like '%'+@FirstName+'%' and rd.CLNO=@CLNO order by TID desc;
	else if(@SSN <>'' and @Apno <>'' and @LastName <>'' and @FirstName <>'' and @CLNO ='')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID=@SSN and rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN <>'' and @Apno ='' and @LastName <>'' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.SSNOrOtherID=@SSN and rd.CLNO=@CLNO and rd.FirstName like '%'+@FirstName+'%' and rd.LastName like '%'+@LastName+'%' order by TID desc;
	else if(@SSN ='' and @Apno <>'' and @LastName <>'' and @FirstName <>'' and @CLNO <>'')
		  select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName,rd.DateReceived,rd.OrderStatus from OCHS_ResultDetails rd LEFT join client c on rd.clno = c.clno where rd.CLNO = @CLNO and rd.OrderIDOrApno = @Apno and rd.FirstName like '%'+@FirstName+'%' and rd.LastName like '%'+@LastName+'%' order by TID desc;
END

