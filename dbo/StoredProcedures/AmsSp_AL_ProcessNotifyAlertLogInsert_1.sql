
----------------------------------------------------------------------
-- AmsSp_AL_ProcessNotifyAlertLogInsert_1
--
-- Process the alertLog insert notification.
--
-- Inputs -
--  @sNotifyData nvarchar(1024) - notification data.
--
-- Outputs -
-- @nALUpdated
-- @nDMLUpdated
-- @nPSAMUpdated
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer - 11/26/2007.
--
CREATE PROCEDURE AmsSp_AL_ProcessNotifyAlertLogInsert_1
@sNotifyData nvarchar(1024),
@nALUpdated int output,
@nDMLUpdated int output,
@nPSAMUpdated int output
AS

set nocount on

declare @nReturn int
set @nReturn = 0
set @nALUpdated = 0
set @nDMLUpdated = 0
set @nPSAMUpdated = 0

-- breakout the alert info from the notifyData.
declare @nEventIdDay int
declare @nEventIdFraction int
declare @sAlertId nvarchar(1024)
declare @nAlertTypeId smallint
declare @sDescription nvarchar(1024)

--print 'AmsSp_AL_ProcessNotifyAlertLogInsert_1: notifyData=' + @sNotifyData

exec @nReturn = AmsSp_NotifyData_CrackAlertLogInsert_1 @sNotifyData,
						@nEventIdDay output,
						@nEventIdFraction output,
						@sAlertId output,
						@nAlertTypeId output

if (@nReturn <> 0)
begin
	return @nReturn
end

-- get the other event info associated with this alert.
declare @dtEventTime datetime
declare @nType int
declare @nCategory int
declare @nBlockKey int
declare @sSource nvarchar(256)
declare @nUserKey int
declare @nComputerId int
select @dtEventTime = EventTime,
		@nType = Type,
		@nCategory = Category,
		@nBlockKey = BlockKey,
		@sSource = Source,
		@nUserKey = UserKey,
		@nComputerId = ComputerId,
		@sDescription = Description
from EventLog with (nolock) where (EventIdDay = @nEventIdDay) and (EventIdFraction = @nEventIdFraction)
if (@dtEventTime is null)
begin
	-- error-- we did not find corresponding eventLog entry for alertLog entry !!!!
--print 'AmsSp_AL_ProcessNotifyAlertLogInsert_1: ERROR-- unable to find eventLog entry for alertLog entry- EventIdDay=' + cast(@nEventIdDay as nvarchar(10)) + ', EventIdFraction=' + cast(@nEventIdFraction as nvarchar(12))
	return -2
end

-- we should pay attention to eventTypes of StatusAlerts.
if (@nType <> 5)
begin
--print 'AmsSp_AL_ProcessNotifyAlertLogInsert_1: ERROR-- event not of statusAlert type- EventIdDay=' + cast(@nEventIdDay as nvarchar(10)) + ', EventIdFraction=' + cast(@nEventIdFraction as nvarchar(12))
	return -3
end

-- ComQA21481.
-- Alerts are not only based on the device (i.e. blockKey) but also on the event-source.
-- per srs-445 device alerts are event-categories 20, 21, 64, 65 and snap-on alerts are
-- 30, 31, 62, 63.
-- Device alerts eminate from AMS host system processes (i.e. plant servers, device alert servers, etc.)
-- whereas snap-on alerts eminate from snap-ons.
-- When we have a device alert the event source is the name of the process (i.e. the machine name of the
-- plant server).  To eliminate any ambiguity we will use 'AMSDMHostProcess' as the AL.AlertSource for
-- device alerts.
-- When we have a snap-on alert we will use the event-source as the AL.AlertSource.
declare @sAlertSource nvarchar(256)
set @sAlertSource = 'AMSDMHostProcess'
declare @bIsSnapOn int
set @bIsSnapOn = 0
if (@nCategory in (30,31,62,63))
begin
	set @sAlertSource = @sSource	-- set equal to snap-on event source.
	set @bIsSnapOn = 1 -- is a snapOn type.
end
if (@nCategory in (74))
begin
	set @sAlertSource = @sSource	-- use set/clears event source.
end

-- we have an alert, we now need to find out if it is a HART alert and then search the alert list for any old
-- 8 character HART alerts.  The reason is that during migration, the alerts get moved over as 8 characters.
-- However, the new HART alerts are 16 characters.  So in order to properly set/clear an old 8 character alert with
-- a new 16 character alert, we need to convert the 16 character alert into its 8 character version using the 
-- old algorithm and then compare that with whats in the database.  Enumerations in the old versions had a problem
-- in that multiple enumerated values mapped to the same 8 character alert.  The only difference is the text that
-- is displayed.  Therefore, we have to also compare the description coming in with the description already in the
-- database.

-- a HART alert is 16 characters of hexadecimal digits
if (@nCategory in (20,21))
begin
	declare @nCnt int
	declare @nIsHex int
	declare @nLength int
	declare @sAlertEight nvarchar(256)
	declare @sDescOld nvarchar(1000)

	-- first check to make sure that the alert does not exist (this would be the case if a 16 character alert comes in
	-- and there are no 16 character alerts that match, but an 8 character alert might)
	select @nCnt = count (*) from AlertList where AlertId = @sAlertId and BlockKey = @nBlockKey and AlertSource = @sAlertSource

	if (@nCnt = 0)
	begin
		-- so now the potential 16 character alert does not exist, lets convert and check to see if 
		-- an 8 character one matches
		set @nIsHex = dbo.AmsUdf_Ext_IsHexadecimal(@sAlertId);  
		set @nLength = LEN(@sAlertId)
		if (@nIsHex = 1 and @nLength = 16)
		begin
			exec @nReturn = dbo.AmsSp_Ext_ConvertToEightCharacterHARTAlert @sAlertId, @sAlertEight output;	
			if (@nReturn = 0)
			begin
				-- now see if 8 character description matches the 16 character one
				select @nCnt = count (*) 
				from AlertList INNER JOIN
				     EventLog ON EventLog.EventIdDay = AlertList.EventIdDay and EventLog.EventIdFraction = AlertList.EventIdFraction
				where AlertId = @sAlertEight and AlertList.BlockKey = @nBlockKey and AlertSource = @sAlertSource and Description = @sDescription

				if (@nCnt = 1)
				begin
					update AlertList set AlertId = @sAlertId
					where  (@nBlockKey = BlockKey) and (@sAlertEight = AlertId) and (@sAlertSource = AlertSource)
				end
			end
		end
	end
end

-- According to srs-445 section 2.2.1. systemLevel alerts are not associated
-- with devices.
-- The blockKey for events logged that are not associated with devices is always set to -1.
declare @sAlertLevel nvarchar(256)
set @sAlertLevel = 'Device'
if (@nBlockKey = -1)
begin
	set @sAlertLevel = 'System'
end
-- NOTE: we are currently ignoring all 'system-level' alerts.
-- NOTE: Remove this when you do start processing system-level alerts.
if (@sAlertLevel = 'System')
begin
	return 0	-- not a loggable alert.
end
-- now determine if we are to log this alert activity to the AlertList.
declare @bIsLoggable int
declare @bAck int
set @bAck = 0
set @bIsLoggable = 0
-- note: we should always log 'clears' to the alertLog.
if (@nCategory in (21,31,61,63,64,65))
begin
	set @bIsLoggable = 1
end
else if (@nCategory = 74)
begin
-- we have an acknowledge alert
	set @bAck = 1
	set @bIsLoggable = 1
end
else
begin
	-- we have a set type alert.
	-- if we have a device alert level then we need to take the scanning status
	-- for this device into account.
	if (@sAlertLevel = 'Device')
	begin
		declare @sDeviceScanningStatus nvarchar(1024)
		exec AmsSp_DevBlk_GetAlertMonitorStatus_1 @nBlockKey, @sDeviceScanningStatus output
		-- if device is in DeviceMonitorList and alertMonitoring enabled then we always log.
		if (@sDeviceScanningStatus = '2')
		begin
			set @bIsLoggable = 1
		end
		-- ComQa22338 - we log regardless if AlertMonitoring is disabled or not / no
		-- matter if the alert came from a SnapOn or not.
		else if (@sDeviceScanningStatus = '3')
		begin
			set @bIsLoggable = 1
		end
		else
		-- all other scanning states we ignore.
		begin
			set @bIsLoggable = 0
		end
	end
	else
	begin
		-- we do not have a device alert level - we must have a system alert level.
		-- we are currently ignoring system alert level.
		-- (in the future - you should add system alert level processing here.)
		set @bIsLoggable = 0
	end
end
if (@bIsLoggable = 0)
begin
	-- we do not have a loggable alert here.
--print 'AmsSp_AL_ProcessNotifyAlertLogInsert_1: Device (' + cast(@nBlockKey as nvarchar(10)) + ') alert logging not enabled at this time...'
	return 0
end
-- end of ComQA21481
--

-- process alertLogInsert based on category type.
-- note: do not include 'unsuppressed' type categories (ie. 60)
if (@nCategory in (20,21,30,31,61,62,63,64,65,74))
begin
	-- determine whether alert is active(1) or inactive(0)
	declare @bIsActive int
	set @bIsActive = 1
	-- include clear's, disabled, and suppressed type.
	if (@nCategory in (21,31,61,63,64,65)) set @bIsActive = 0

--print 'AmsSp_AL_ProcessNotifyAlertLogInsert_1: We have valid category(' + cast(@nCategory as nvarchar(10)) + '), IsActive(' + cast(@bIsActive as nvarchar(10)) + ')'

	-- process the device alert.
	declare @dtAlTime datetime
	declare @nAlBlockKey int
	declare @sAlAlertId nvarchar(1024)
	declare @nAlEventIdDay int
	declare @nAlEventIdFraction int
	declare @sAlAlertSource nvarchar(256)
	declare @nAck int
	declare @nAlertState int
	declare @nSetCount int
	-- get the current active alert for this device and alertId if any.
	select @dtAlTime = AlertTime,
			@nAlBlockKey = BlockKey,
			@sAlAlertId = AlertId,
			@sAlAlertSource = AlertSource,
			@nAlEventIdDay = EventIdDay,
			@nAlEventIdFraction = EventIdFraction,
			@nSetCount = SetCount,
			@nAck = AckState,
			@nAlertState = AlertState
	from AlertList with (nolock)
	where (@nBlockKey = BlockKey) and (@sAlertId = AlertId) and (@sAlertSource = AlertSource)

	-- if this alert was caused by the same event currently in the AL then ignore it.
	if (@nAlEventIdDay = @nEventIdDay) and (@nAlEventIdFraction = @nEventIdFraction)
	begin
--print 'AmsSp_AL_ProcessNotifyAlertLogInsert_1: Alert with same eventId currently logged; Eid=' + cast(@nEventIdDay as nvarchar(10)) + '.' + cast(@nEventIdFraction as nvarchar(10)) + ', AlEid=' + cast(@nAlEventIdDay as nvarchar(10)) + '.' + cast(@nAlEventIdFraction as nvarchar(10))
		return 0
	end

--print 'AmsSp_AL_ProcessNotifyAlertLogInsert_1: alertId(' + isnull(@sAlertId, '<null>') + '), AL-alertId(' + isnull(@sAlAlertId, '<null>') + '), IsActive(' + cast(@bIsActive as nvarchar(10)) + ')'

	declare @dt datetime
	-- process this alert.
	if (@bIsActive = 1)
	begin
		-- an ack is represented as an active alert
		if (@bAck = 1)
		begin
			if (@sAlAlertId is null)
			begin
				-- we do not have an alert for this ack, something is wrong
				return -4
			end
			else
			begin
				-- we do have an alert for this ack, check its state
				if (@nAlertState = 1)
				begin
					-- the alert is still set
					update AlertList
					set AckState = 1
					where  (@nBlockKey = BlockKey) and (@sAlertId = AlertId) and (@sAlertSource = AlertSource)
					set @dt = GETUTCDATE()
					exec AmsSp_ALTrack_ALDeviceUpdated_1 @nBlockKey, @dt, 2
					set @nALUpdated = 1
				end
				else
				begin
					-- the alert is cleared
					delete AlertList with (rowlock) where (@nBlockKey = BlockKey) and (@sAlertId = AlertId) and (@sAlertSource = AlertSource)
					set @dt = GETUTCDATE()
					exec AmsSp_ALTrack_ALDeviceUpdated_1 @nBlockKey, @dt, 3
					set @nALUpdated = 1
				end
			end
		end
		else
		begin
			-- process the active alert.
			if (@sAlAlertId is null)
			begin
				-- we currently do NOT have an alert for this device.
				insert into AlertList with (rowlock) (EventIdDay, EventIdFraction, AlertTime, BlockKey, AlertId, AlertSource, AckState, AlertState, SetCount)
				values (@nEventIdDay, @nEventIdFraction, @dtEventTime, @nBlockKey, @sAlertId, @sAlertSource, 0, 1, 1)
--print 'device alert added...'

				declare @sAuto nvarchar(255)
				select @sAuto = Data from SystemDefaults where Parameter = 'AutoAcknowledgeAlerts'
				if (@@rowcount = 1)
				begin
					if (@sAuto = 'true')
					begin
						-- send a log event for acknowledge
						declare @nSPReturn int
						declare @sEventDateTime nvarchar(50)
						declare @sUser nvarchar(256)

						select @sUser = UserName from Users where UserKey = @nUserKey

						if (@@rowcount = 1)
						begin
							-- let the logEventSummary assign the current time. 
							
							set @sDescription = 'Auto-Acknowledge - ' + @sDescription
							set @sEventDateTime = 'NO_EVENTTIME'

							declare @sUid nvarchar(256)

							set @sUid = 'ALERT_UNKNOWN_ID'

							select @sUid = Uid
							from AlertTypes
							where AlertTypeId = @nAlertTypeId

							exec @nSPReturn = AmsSp_LogEventSummary_1  @sEventDateTime,
												@sUser, -- UserName
												@nComputerId, -- ComputerNameId
												@nBlockKey,
												0, -- eventCode
												@sSource, -- ApplicationName
												5, -- eventTypeId -- Status Alert
												74, -- eventCategoryId - -- Acknowledge'
												@sDescription,
												0, '',	-- otherBufLen and otherBuf
												0,		-- archived
												@sUser, -- UserName
												@nEventIdDay output,
												@nEventIdFraction output,
												@sAlertId,		-- alertId,
												@sUid,		-- alertType,
												'',		-- moreDetail,
												''		-- operationType
							if (@nSPReturn <> 0)
							begin
								print 'AmsSp_AL_ProcessNotifyAlertLogInsert_1 - LogEventSummary returned ' + cast(@nSPReturn as nvarchar(10))
							end
						end
					end
				end

				set @dt = GETUTCDATE()
				exec AmsSp_ALTrack_ALDeviceUpdated_1 @nBlockKey, @dt, 1
				set @nALUpdated = 1
			end
			else
			begin
				-- we currently have an alert for this device.
				if (@dtAlTime <= @dtEventTime)
				begin
					-- update alert with more current time
					update AlertList
					set AlertTime = @dtEventTime,
						EventIdDay = @nEventIdDay,
						EventIdFraction = @nEventIdFraction,
						SetCount = @nSetCount + 1,
						AlertState = 1
					where  (@nBlockKey = BlockKey) and (@sAlertId = AlertId) and (@sAlertSource = AlertSource)
--print 'device alert updated...'
					set @dt = GETUTCDATE()
					exec AmsSp_ALTrack_ALDeviceUpdated_1 @nBlockKey, @dt, 2
					set @nALUpdated = 1
				end
			end
		end
	end
	else
	begin
		if (@sAlAlertId is not null)
		begin
			-- we currently have an alert for this device.
--print 'Alert clear; ALTime =' + cast(@dtAlTime as nvarchar(50)) + ', EventTime=' + cast(@dtEventTime as nvarchar(50))
			-- make sure the clear time is more recent than the active time in the alertList.
			if (@dtAlTime <= @dtEventTime)
			begin
				-- if the alert is not acknowledged, we need to keep the alert and change its alertState
				if (@nAck = 0)
				begin
					-- SCR AOEP00028703 - clears were updating the time stamp of a set
					-- only sets can update the time stamp
					update AlertList 
					set AlertState = 0
					where  (@nBlockKey = BlockKey) and (@sAlertId = AlertId) and (@sAlertSource = AlertSource)
--print 'device alert updated...'
					set @dt = GETUTCDATE()
					exec AmsSp_ALTrack_ALDeviceUpdated_1 @nBlockKey, @dt, 2
					set @nALUpdated = 1
				end
				else
				begin
					delete AlertList with (rowlock) where (@nBlockKey = BlockKey) and (@sAlertId = AlertId) and (@sAlertSource = AlertSource)
--print 'device alert cleared...'
					set @dt = GETUTCDATE()
					exec AmsSp_ALTrack_ALDeviceUpdated_1 @nBlockKey, @dt, 3
					set @nALUpdated = 1
				end
			end
		end
	end
end

return @nReturn

GO

