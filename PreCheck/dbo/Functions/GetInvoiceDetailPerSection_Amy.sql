


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- select  [dbo].[GetInvoiceDetailPerSection_Amy] (4467187,2,'crim') [Crim Addtl Charges]
-- select  [dbo].[GetInvoiceDetailPerSection_Amy] (4467187,2,'crimpassthru') [Crim Service Charge]
-- =============================================
CREATE FUNCTION [dbo].[GetInvoiceDetailPerSection_Amy]  
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
		where  apno=@Apno and type=@type and (description like '%service charge%' or subKeyChar=1) group by apno
else if @type=2 and  @sect = 'crim'
		select  @Charge = sum(amount) from invdetail (NOLOCK)
		where  apno=@Apno and type=@type and ( description not like '%service charge%'  or description like '%Criminal search%') group by apno
	/*

	Cri,[dbo].GetInvoiceDetailPerSection (a.apno,2,'crim') [Crim Addtl Charges]     ---
	Crim Addtl Charge: total should be for this report for this column (Z) $20.25

,[dbo].GetInvoiceDetailPerSection (a.apno,2,'crimpassthru') [Crim Service Charge]   ---
Crim Service Charge column: total for this column (AA) should be $95.00


	else if @type in (7,8) 
		select  @Charge = sum(amount) from invdetail 
		where  apno=@Apno and type in (7,8)   group by apno
	else if @type in (1,6) 
		select  @Charge = sum(amount) from invdetail 
		where  apno=@Apno and type in (1,6)   group by apno
	*/
	else
		select  @Charge = sum(amount) from invdetail (NOLOCK)
		where  apno=@Apno and type=@type  group by apno

Return isnull(@Charge,0)
END



