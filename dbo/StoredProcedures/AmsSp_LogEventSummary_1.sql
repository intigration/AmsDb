-----------------------------------------------------------------------
-- AmsSp_LogEventSummary_1
--
-- Log an event.
--
-- This will log a single event summary data to the database.
--
-- Note --
-- * if the Ams user name is not in the database it will use File Server
--   user name instead.
--
-- Inputs -
--	@strEventTimeAsGMT nvarchar(50)
--		This is when the event occurred
--		Client is exepected to pass time in 
--		'ODBC canonical (with milliseconds)' format: yyyy-mm-dd hh:mi:ss.mmm(24h) 
--		Note: this time is in GMT
--      	Note: this is passed as a string to avoid time-window differences
--           	      between SqlServer date's and C++/VB dates
--	@strAmsUserName nvarchar(256)
--		This is the Ams user name (i.e. the 'who') of the event.
--	@iComputerNameId int
--		This is the computer IP address (i.e. the 'where') of the event.
--	@nBlockKey int
--		This is the Block Key.
--	@nEventCode smallint
--		This is the Event Code (always be 0).
--	@strEventSourceApplication nvarchar(256)
--		Some additional where for the event.
--	@strEventTypeId nvarchar smallint
--		This is the ID of the event type.
--	@strEventCategoryId smallint
--		This is the ID of the event category.
--	@strEventReason nvarchar(1024)
--		This is the 'why' for the event.
--	@nOtherBufLen smallint
--	@strOther nvarchar(255)
--	@nArchived smallint
--	@strPSUserNameName nvarchar(255)
--		This is the File Server name.  Format is 'FS.<computerName>' and the
--		the client is responsible for formatting this up.
--	@nEventIdDay as int output,
--	@nEventIdFraction as int output
--	@strAlertId nvarchar(1024)
--	@strAlertTypeUid nvarchar(255)
--	@strMoreDetail nvarchar(max)
--  @sOperationType nvarchar(256) - the type of operation associated with this event.
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to log event.
--      -2 - Error, strEventTimeAsGMT is not a valid date
--	-3 - Error, invalid @iAlertTypeId 
--	-4 - Error, status alert not associated with a device or
--		    alert associated device not in the device monitor list or
--		    scan is disable for the alert associated device or
--		    alert monitor is disable on the server where the alert associated device resides.
--	-5 - unable to find event for manual clear operation.
--  -6 - alert was filtered, no logging was done
--
-- James Kramer 12/03/2007
--
CREATE PROCEDURE AmsSp_LogEventSummary_1
@strEventTimeAsGMT nvarchar(50),
@strAmsUserName nvarchar(50),
@iComputerId int,
@nBlockKey int,
@nEventCode smallint,
@strEventSourceApplication nvarchar(50),
@nEventTypeId smallint,
@nEventCategoryId smallint,
@strEventReason nvarchar(1024),
@nOtherBufLen smallint,
@strOther nvarchar(255),
@nArchived bit,
@strFSUserName nvarchar(255),
@nEventIdDay as int output,
@nEventIdFraction as int output,
@strAlertId nvarchar(1024),
@strAlertTypeUid nvarchar(255),
@strMoreDetail nvarchar(max),
@sOperationType nvarchar(256)
AS
declare @iAmsUserKey smallint
declare @iReturn int
declare @iReturn2 int
declare @dtEventTimeAsGMT datetime

-- we may have some special processing to do before get started here.
if (@sOperationType = 'ManualClear')
begin
	-- we need to set the eventCategory to appropriate clear state for
	-- the event that originally set this.
	-- the original event is the one identified by the eventIdDay & Fraction
	-- sent in by the client.
	exec @iReturn = AmsSp_GetEventCategoryFromEventId @nEventIdDay,
							@nEventIdFraction,
							@nEventCategoryId output,
							@strEventSourceApplication output
	if (@iReturn <> 0)
		return -5
	if (@nEventCategoryId = 20)
		set @nEventCategoryId = 21
	else if (@nEventCategoryId = 30)
		set @nEventCategoryId = 31
	else if (@nEventCategoryId = 62)
		set @nEventCategoryId = 63
end

-- for acknowledge alerts, we need to retrieve the event source of the alert we are acknowledging
if (@nEventCategoryId = 74)
begin
	select @strEventSourceApplication = AlertSource 
	from AlertList
	where BlockKey = @nBlockKey and AlertId = @strAlertId
end

-- verify date/time is a valid date/time
IF  @strEventTimeAsGMT<> 'NO_EVENTTIME' and isdate(@strEventTimeAsGMT) = 0
	return -2

-- get EventIdDay and EventIdFrac
exec @iReturn =AmsSp_GenerateEventId_1 @strEventTimeAsGMT OUTPUT, @nEventIdDay OUTPUT,@nEventIdFraction OUTPUT
if (@iReturn <> 0) 
begin
	return -1
end

--convert the EventTime from nvarchar back to datetime
set  @dtEventTimeAsGMT = cast(@strEventTimeAsGMT as datetime) 

-- get / add the Ams user.
exec @iReturn = AmsSp_AmsUser_GetKey_1 @strAmsUserName,@strFSUserName,@iAmsUserKey OUTPUT
if (@iReturn <> 0) and (@iReturn <> 1)
begin
	return -1
end

-- we only disregard alerts if they are device alerts for devices that are not in
-- the device monitor list
if (@nEventCategoryId in (20,21))
begin
	select BlockKey
	from DeviceMonitorList
	where BlockKey = @nBlockKey

	if (@@rowcount = 0)
	begin
		return -6
	end

	-- now grab the default alert type from the database -only if the alertTypeID == ALERT_UNKNOWN_ID
	if (@strAlertTypeUid = 'ALERT_UNKNOWN_ID')
	begin
		select  @strAlertTypeUid = Uid
		from AlertTypes INNER JOIN
			 DeviceAlertDesc ON AlertTypes.AlertTypeId = DeviceAlertDesc.AlertTypeId INNER JOIN
			 Devices on DeviceAlertDesc.AmsDevRevId = Devices.AmsDevRevId INNER JOIN
			 Blocks on Devices.DeviceKey = Blocks.DeviceKey
		where BlockKey = @nBlockKey and AlertId = @strAlertId
	end
end

-- now go ahead and log the event.
insert EventLog with (rowlock) (EventIDDay,
		 EventIdFraction,
		 EventTime,
		 UserKey,
		 ComputerId,
		 BlockKey,
		 EventCode,
		 Source,
		 Type, 
		 Category, 
		 Description,
		 OtherBufLen, 
		 Other,
		 Archived,
		 MoreDetail)
values (@nEventIdDay, 
	@nEventIdFraction,
	@dtEventTimeAsGMT,
	@iAmsUserKey,
	@iComputerId, 
	@nBlockKey,
	@nEventCode,
	@strEventSourceApplication,
	@nEventTypeId,
	@nEventCategoryId,
	@strEventReason,
	@nOtherBufLen,
	@strOther,
	@nArchived,
	@strMoreDetail)

if @@ERROR!= 0 
	set @iReturn2 = -1
else
    begin
	set @iReturn2 = 0
    end

-- Log Alert event if the alertTypeUID is not blank.
if ( @iReturn2 = 0 ) and ( @strAlertTypeUid <> '' )
    begin
	-- verify alert type id
	declare @iAlertTypeId int

	exec @iReturn = AmsSp_GetAlertTypeId_1 @strAlertTypeUid, @iAlertTypeId OUTPUT
	if (@iReturn <> 0)
	begin
		print 'Unable to retrieve AlertTypeId'
		return -3
	end

	-- we have a valid alert type.
	-- go ahead and log the alert.
	insert AlertLog with (rowlock) (EventIdDay, EventIdFraction, AlertId, AlertTypeId)
	values (@nEventIdDay, @nEventIdFraction, @strAlertId, @iAlertTypeId)

	-- place the alert on notifyQ
	EXEC AmsSp_NotifyQ_PushAlertLogInsert_1 @nEventIdDay,
						@nEventIdFraction,
						@strAlertId,
						@iAlertTypeId
    end
else
	begin
	-- place the event on the notifyQ
	EXEC AmsSp_NotifyQ_PushEventLogInsert_1 @nEventIdDay,
						@nEventIdFraction,
						@dtEventTimeAsGMT,
						@nEventTypeId,
						@nEventCategoryId,
						@nBlockKey
	end

if @@ERROR!= 0 
	set @iReturn2 = -1
else
    begin
	set @iReturn2 = 0
    end

return @iReturn2

GO

