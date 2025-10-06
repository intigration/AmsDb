
-----------------------------------------------------------------------
-- AmsSp_GenerateEventId_1
--
-- This will generate EventIdDay and EventIdFraction base on the current time
--
--
-- Inputs -
--	@sEventTime nvarchar(50)
--		This is the event time
--	@nEventIdDay int output
--		This is the Event Id.
--	@nEventIdFraction int output
--		This is the Event Id.
-- Returns -
--	0 - successful.
--	-1 - Error, unable to creat Id.
--
-- Jane Xiao, 7/15/2003
-- Jane Xiao, 9/26/2003 
--	To fix the issue between Event Time and EventId conversion, 
--	the EventTime is changed to support 10�s of milliseconds resolution 
--	instead of 100�s of milliseconds resolution.
-- Jane Xiao, 10/1/2003
--	Change the output event time string to support 1 second resolution
--
CREATE PROCEDURE AmsSp_GenerateEventId_1
@strEventTimeAsGMT as nvarchar(50) output,
@nEventIdDay as int output,
@nEventIdFraction as int output
AS
-- 
declare @iReturn int
declare @nEventTime float(53)
declare @dtEventTimeAsGMT datetime 
declare @nGetId int
declare @sGMT as nvarchar(50)
declare @nFlag as int
declare @sLatestTime as nvarchar(50)
declare @sOldestTime as nvarchar(50)
declare @dtTemp as datetime

if @strEventTimeAsGMT = 'NO_EVENTTIME'
	begin
		-- set to current UTC time.
		set @sGMT = convert(nvarchar, GETUTCDATE(), 121)
		set @sGMT = substring(@sGMT, 1, len(@sGMT) - 1) + '0'
	end
else if isDate(@strEventTimeAsGMT) = 1
	begin
		set @dtTemp = cast(@strEventTimeAsGMT as datetime)
		set @sGMT = convert(nvarchar, @dtTemp, 121)
		set @sGMT = substring(@sGMT, 1, len(@sGMT) - 1) + '0'
		set @sLatestTime = @sGMT
		set @sOldestTime = @sGMT
	end 
else
	return -3	-- invalid datetime.

set @nGetId = 0
set @nFlag = 0

while @nGetId = 0
begin
	--convert the EventTime from nvarchar back to datetime
	set @dtEventTimeAsGMT = cast(@sGMT as datetime)
	set @nEventTime = cast(@dtEventTimeAsGMT as float(53))
	
	--Calculate EventIdDay and EventIdFraction in a VT_DATE format, IN GMT
	-- We add 2.0 to convert this to a genuine VT_DATE value, which starts at 12/30/1899, NOT 1/1/1900
	set @nEventTime = @nEventTime + 2.0
	set @nEventIdDay = cast(@nEventTime as int)
	set @nEventIdFraction = cast(((@nEventTime- @nEventIdDay) * 2147483648.0 + 0.5) as int)

	--make sure the EventIds are unique
	select * from EventLog with (nolock)
	where EventIdDay = @nEventIdDay
	and EventIdFraction = @nEventIdFraction
	
	if @@rowcount = 0 
	begin
		set @nGetId = 1
		--remove millisecond from EventTime string, because Convert function does not do rounding, so we need to
		-- add 500 millisecond. 
		set @strEventTimeAsGMT = convert(nvarchar, dateadd(millisecond, 500, cast(@sGMT as datetime)), 120)
	end
	else
	begin
		-- we have a duplicate eventId.
		-- if we orginally generated the event then insert a little delay and try next time interval.
		-- wait for a little time to try this again.
		if @strEventTimeAsGMT = 'NO_EVENTTIME'
		    	begin
				waitfor delay '00:00:00.01'
				set @sGMT = convert(nvarchar, GETUTCDATE(), 121)	
		    	end
		else 
			--client passed in duplicate time, we'll generate
			-- a new time that is closest to the passed in time.  
			begin
				if @nFlag = 0
				      begin
					set @sGMT = @sLatestTime
					set @dtTemp = cast(@sGMT as datetime)
					-- add 10 milliseconds
					set @dtTemp = dateadd(millisecond, 10, @dtTemp)
					set @sGMT = convert(nvarchar, @dtTemp, 121)
					set @sLatestTime = @sGMT
					set @nFlag = 1
				      end
				else -- @nFlag = 1
				      begin
					set @sGMT = @sOldestTime
					set @dtTemp = cast(@sGMT as datetime)
					--substract 10 milliseconds
					set @dtTemp = dateadd(millisecond, -10, @dtTemp)
					set @sGMT = convert(nvarchar, @dtTemp, 121)
					set @sOldestTime = @sGMT
					set @nFlag = 0
				      end
			end
	end
end

if @@ERROR <> 0 
	set @iReturn = -1
else  
	set @iReturn = 0

return @iReturn

GO

