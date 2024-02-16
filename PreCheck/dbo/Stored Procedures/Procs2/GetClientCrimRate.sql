CREATE PROCEDURE [dbo].[GetClientCrimRate]
	@CLNO smallint,
	@CNTY_NO int,
	@Rate smallmoney OUTPUT,
	@ExcludeFromRules bit OUTPUT
AS
SET NOCOUNT ON

/*
--MDAnderson(and maybe others) gets charged the same price for all county criminal searches
--check if this a client with one county pricing
Declare @OneCountyPricing as bit
Declare @OneCountyPrice as money
SET @ExcludeFromRules=0  --(FALSE)--don't exclude from pricing rules if there is one county pricing 

--Get Rate on assumption of one county pricing
SELECT @Rate=OneCountyPrice,@OneCountyPricing = OneCountyPricing 
FROM Client Where CLNO=@CLNO

--if not one county prcing, check prices for this client the regular way
-- if this sp returns null, get the default price for this county
if @OneCountyPricing=0 begin
  SET @Rate = null    --prepare value in case following SELECT fails
  SELECT @Rate = Rate, @ExcludeFromRules=ExcludeFromRules
  FROM ClientCrimRate
  WHERE (CLNO = @CLNO)
    AND (CNTY_NO = @CNTY_NO)
end
*/

--ExcludeFromRules has priority over OneCountyPricing

--MDAnderson(and maybe others) gets charged the same price for all county criminal searches
--check if this a client with one county pricing
Declare @OneCountyPricing as bit
Declare @OneCountyPrice as money

--Get Rate on assumption of one county pricing
--SET @OneCountyPricing=0  --(FALSE)--default in case SELECT fails
SELECT @OneCountyPrice=OneCountyPrice,@OneCountyPricing = OneCountyPricing 
FROM Client Where CLNO=@CLNO

--if not one county prcing, check prices for this client the regular way
-- if this sp returns null, get the default price for this county
--if @OneCountyPricing=0 begin
 SET @Rate = null    --prepare value in case following SELECT fails
 SET @ExcludeFromRules=0  --(FALSE)--default in case SELECT fails
  SELECT @Rate = Rate, @ExcludeFromRules=ExcludeFromRules
  FROM ClientCrimRate
  WHERE (CLNO = @CLNO)
    AND (CNTY_NO = @CNTY_NO)
--end

if @OneCountyPricing=1 and @ExcludeFromRules=0 
  SET @Rate = @OneCountyPrice
