
-------------------------------------------------------------------------------
-- AmsUdf_EventIdDayFractionToDateTime 
--
-- Convert EventIdDay and EventIdFraction to DateTime data type
--
-- Inputs --
--	@iEventIdDay int - Day part of the event.
--  @iEventIdFraction int - Fraction part of the event.
--
-- Outputs --
--	@dtEventDate as DateTime
--
-- Author --
--	Nghy Hong
--	9/25/06
--
CREATE FUNCTION AmsUdf_EventIdDayFractionToDateTime
(@iEventIdDay int, @iEventIdFraction int)  
RETURNS DateTime
AS  
BEGIN 
	declare @dtEventDate Datetime
	--Converting EventIdDay and EventIdFraction representing VT_DATE to sql datetime data type
	--We need to subtract 2.0 from the day part of the VT_DATE, because VT_DATE starts at 12/30/1899
	--and datetime data type starts at 1/1/1900. 
	set @dtEventDate = cast( ( (cast(@iEventIdDay as float(53)) - 2.0) + 
							   (cast(@iEventIdFraction as float(53)) / 2147483648.0) ) as datetime)

	return @dtEventDate
END

GO

