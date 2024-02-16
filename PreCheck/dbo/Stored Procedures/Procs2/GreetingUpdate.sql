
CREATE PROCEDURE [dbo].[GreetingUpdate]
(
	@GreetingID int,
	@Greeting varchar(max),
	@Holiday varchar(8000)
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.Greeting 
set Greeting=@Greeting,
    Holiday=@Holiday 
where GreetingID=@GreetingID

SELECT GreetingID, Greeting, Holiday FROM dbo.Greeting WHERE (GreetingID = @GreetingID)
