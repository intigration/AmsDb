
----------------------------------------------------------------------
-- AmsSp_ALTrack_HasBeenAdded_1
--
-- Checks to see if AL has had an alert added from a point in time.
--
-- Inputs -
--  checkDateTimeValue
--
-- Outputs -
--  bVal - true or false.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_ALTrack_HasBeenAdded_1
@dtLastGetTime datetime,
@bResult int output
AS
set nocount on
declare @nReturn int
set @nReturn = 0
set @bResult = 0

--print '@dtLastGetTime=' + convert(nvarchar(30), @dtLastGetTime, 126)

declare @dtTmpDateTime datetime
set @dtTmpDateTime = '1970/01/01 00:00:00'

-- we are looking collectively at all plantServers.
select @dtTmpDateTime = AlertList_UpdateTracking.LastAddTime
from AlertList_UpdateTracking with (nolock)

--print '@dtTmpDateTime=' + convert(nvarchar(30), @dtTmpDateTime, 126)

if (@dtTmpDateTime <> '')
begin
	if (@dtTmpDateTime > @dtLastGetTime)
	begin
		set @bResult = 1
	end
	else
	begin
		set @bResult = 0
	end
end

return @nReturn

GO

