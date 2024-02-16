


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetInvoiceDetailPerSection]  
(
	-- Add the parameters for the function here
	@Apno int,@type int, @sect varchar(20)
)
RETURNS FLOAT
AS
BEGIN
	Declare @Charge FLOAT

	if @type=4 and  @sect = 'social'
		select  @Charge = sum(amount) from invdetail (NOLOCK)
		where  apno=@Apno and type=@type and description like 'S%' group by apno
	else if @type=4 and  @sect = 'credit'
		select  @Charge = sum(amount) from invdetail (NOLOCK)
		where  apno=@Apno and type=@type and description like 'C%' group by apno
	else if @type=2 and  @sect = 'crimpassthru'
		select  @Charge = sum(amount) from invdetail (NOLOCK)
		where  apno=@Apno and type=@type and description like '%service charge%' group by apno
else if @type=2 and  @sect = 'crim'
		select  @Charge = sum(amount) from invdetail (NOLOCK)
		where  apno=@Apno and type=@type and description not like '%service charge%' group by apno
--else if @type=2 and  @sect = 'crim'
--		select  @Charge = sum(amount) from invdetail (NOLOCK)
--		where  apno=@Apno and type=@type and description like '%Criminal Search%' group by apno 
--		--where  apno=@Apno and type=@type and description like '%service charge%' group by apno 
--else if @type=2 and  @sect = 'crimpassthru'
--		select  @Charge = sum(amount) from invdetail (NOLOCK)
--		where  apno=@Apno and type=@type and description not like '%Criminal Search%' group by apno
	/*
	else if @type in (7,8) 
		select  @Charge = sum(amount) from invdetail 
		where  apno=@Apno and type in (7,8)   group by apno
	else if @type in (1,6) 
		select  @Charge = sum(amount) from invdetail 
		where  apno=@Apno and type in (1,6)   group by apno
	*/
	else
		if (@type = null)
		
			select  @Charge = sum(amount) from invdetail (NOLOCK)
			where  apno=@Apno and type in (6,7,8)  group by apno		
		ELSE
			select  @Charge = sum(amount) from invdetail (NOLOCK)
			where  apno=@Apno and type=@type  group by apno

Return isnull(@Charge,0)
END



