-- Create Procedure AIMS_GetAllIrisPendingOrder_Counts
CREATE PROCEDURE AIMS_GetAllIrisPendingOrder_Counts
	
AS
BEGIN
declare @num_of_crims int 
declare @sectionkeyid varchar(100)
declare @iris_pending_order_count int

select @num_of_crims = (select count(*) from DataXtract_RequestMapping (nolock) where Section = 'Crim' and IsAutomationEnabled = 1)

declare @temp table(
Section varchar(100),
SectionID nvarchar(max),
Apno nvarchar(max),
County varchar(100),
Cnty_No int,
Ordered datetime,
"Last" varchar(100),
"First" varchar(100),
Middle varchar(100),
DOB datetime,
DOB_MM int,
DOB_DD int,
DOB_YYYY int,
SSN varchar(50),
SSN1 varchar(3),
SSN2 varchar(2),
SSN3 varchar(4),
KnownHits varchar(max)
)

declare @output table
(
	SectionKeyId varchar(100),
	Iris_Pending_Count int
)

declare crim_cursor cursor for select SectionKeyId from DataXtract_RequestMapping (nolock) where Section = 'Crim' and IsAutomationEnabled = 1
open crim_cursor
while @num_of_crims > 0
	begin
		fetch crim_cursor into @sectionkeyid
		insert into @temp EXEC dbo.[IRIS_PendingOrders_Integrations] @sectionkeyid, 0,0
		set @iris_pending_order_count = (select count(*) from @temp)
		insert into @output (SectionKeyId, Iris_Pending_Count) VALUES (@sectionkeyid, @iris_pending_order_count)
		delete from @temp
		set @num_of_crims = @num_of_crims - 1
	end
close crim_cursor
deallocate crim_cursor

select c.County,op.* from @output op inner join dbo.TblCounties c on op.SectionKeyId = c.CNTY_NO 



END
