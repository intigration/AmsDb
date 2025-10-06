

-----------------------------------------------------------------------
-- AmsSp_LogDevCommDeCommEvent_1
--
-- Log Device Commission/Decommission event.
--
-- This will log a single Commission/Decommission event to the database.
-- The device's current tag name will be renamed to the new given tag name.
-- Set HostPath and HostTag to blank in DeviceLocation table for decommission event.
--
-- Note --
-- * if the Ams user name is not in the database it will use File Server
--   user name instead. (Implemented by AmsSp_LogEventSummary_1 stored procedure)
--
-- Inputs -
--  @strTag nvarchar(255)  Device's tag
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
--		This is the Device level BlockKey.
--	@strEventSourceApplication nvarchar(256)
--		Some additional where for the event.
--	@strEventTypeId nvarchar smallint
--		This is the ID of the event type.
--	@strEventCategoryId smallint
--		This is the ID of the event category.
--	@strEventReason nvarchar(1024)
--		This is the 'why' for the event.
--	@strPSUserNameName nvarchar(255)
--		This is the File Server name.  Format is 'FS.<computerName>' and the
--		the client is responsible for formatting this up.
--	@nEventIdDay as int output,
--	@nEventIdFraction as int output,
--	@sFinalAmsTag nvarchar(255) output,
--		This is the Ams tag that the device is associated after logging the event
--  @bRenameTagOnDecommission int 
--		This is to be used as boolean to tell the stored procedure 
--		to rename device's tag or not for decommission event.  
--		1 => TRUE otherwise FALSE
--
-- Returns -
--	0 - successful.
--	-1 - Error, wrong event category being passed in.
--  -2 - Error, missing required tag 
--	-3 - Error, log event
--	-4 - Error, tag rename
--
-- Nghy Hong 9/8/2006

CREATE PROCEDURE AmsSp_LogDevCommDeCommEvent_1
@strTag nvarchar(255),
@strEventTimeAsGMT nvarchar(50),
@strAmsUserName nvarchar(50),
@iComputerId int,
@nBlockKey int,		--Device level BlockKey
@strEventSourceApplication nvarchar(50),
@nEventTypeId smallint,
@nEventCategoryId smallint,
@strEventReason nvarchar(1024),
@strFSUserName nvarchar(255),
@nEventIdDay as int output,
@nEventIdFraction as int output,
@sFinalAmsTag nvarchar(255) output,
@bRenameTagOnDecommission int 	
AS
declare @iReturn int
set @iReturn = 0	--Successful
set @sFinalAmsTag = ''

--Make sure this is device commission/decommission event
if (@nEventCategoryId <> 72 and @nEventCategoryId <> 73)
begin
  print 'Wrong event, expect commission or decommission event'
  return -1
end

--Make sure a tag is provided
if len(@strTag) = 0
begin
  print 'A tag is required for a commission event'
  return -2
end

--Get the device's current commissionning status (commission or decommission)
declare @iCurrentComStatus int
SELECT TOP 1 @iCurrentComStatus = Category
FROM EventLog
WHERE (BlockKey = @nBlockKey) AND (Category = 72) OR
      (BlockKey = @nBlockKey) AND (Category = 73)
ORDER BY EventTime DESC

--Get the tag that is currently assigned to this device
declare @DevCurrentTag nvarchar(255)
SELECT @DevCurrentTag = ExtBlockTags.ExtBlockTag
FROM ExtBlockTags INNER JOIN
     BlockAsgms ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey
WHERE (BlockAsgms.BlockKey = @nBlockKey) AND 
	(BlockAsgms.EventIdDayOut = 49710) AND
	(BlockAsgms.EventIdFractionOut = 0) 

--Check the device has been commissioned/decommissioned. 
if ( @nEventCategoryId = @iCurrentComStatus )  
begin
	--Device has been commissioned/decommission,
	--our work is done.
  	set @sFinalAmsTag = @DevCurrentTag
end
else
begin
	declare @sDevNewTag nvarchar(255)
	set @sDevNewTag = @strTag

	--Rename device's tag to device's identifier if this is a decommission event and we are told to do tag rename.
	if (@nEventCategoryId = 73 and @bRenameTagOnDecommission = 1)  -- 1 => TRUE
	begin
	  SELECT @sDevNewTag = Devices.Identifier
	  FROM Devices INNER JOIN Blocks ON Devices.DeviceKey = Blocks.DeviceKey
	  WHERE (Blocks.BlockKey = @nBlockKey) AND (Blocks.BlockIndex = 0)
	  --AOEP00037792 - host tag needs to be FF physical device Id instead of AMS FF device Id
	  if (LEN(@sDevNewTag) > 8)
	  begin
		  select @sDevNewTag = Left(@sDevNewTag, LEN(@sDevNewTag) - 8)
	  end
	end

	if (@nEventCategoryId = 73 and @bRenameTagOnDecommission = 0)  -- 0 => FALSE
	begin
		set @sDevNewTag = @DevCurrentTag
	end	

	begin transaction
	--Log the commission event
	exec @iReturn = AmsSp_LogEventSummary_1	@strEventTimeAsGMT,
											@strAmsUserName,
											@iComputerId,
											@nBlockKey,	--Device level BlockKey
											0,		--EventCode (always 0)
											@strEventSourceApplication,
											@nEventTypeId,
											@nEventCategoryId,
											@strEventReason,
											0,		--OtherBufLen
											'',		--Other
											0,		--Archived
											@strFSUserName,
											@nEventIdDay output,
											@nEventIdFraction output,
											'',		-- AlertId,
											'',		-- AlertTypeUid,
											'',		-- MoreDetail,
											''		-- OperationType
	
	if ( @iReturn <> 0 )
	begin
	  rollback transaction
	  print 'AmsSp_LogEventSummary_1 failed'
	  return -3
	end

	--We need to do a Tag-Rename Ops if the tag given is not currently assigned to the device.
	if (@DevCurrentTag <> @sDevNewTag)
	begin
		--Generate an event to do the tag assignment.
		declare @nTagAssignmentEventIdDay int
		declare @nTagAssignmentEventIdFraction int
		exec @iReturn = AmsSp_LogEventSummary_1	'NO_EVENTTIME',
												@strAmsUserName,
												@iComputerId,
												@nBlockKey,	--Device level BlockKey
												0,		--EventCode (always 0)
												@strEventSourceApplication,
												1,		--Event type = Config change 
												1,		--Event category = Change performed by AMS Device Manager
												@strEventReason,
												0,		--OtherBufLen
												'',		--Other
												0,		--Archived
												@strFSUserName,
												@nTagAssignmentEventIdDay output,
												@nTagAssignmentEventIdFraction output,
												'',		-- AlertId,
												'',		-- AlertTypeUid,
												'',		-- MoreDetail,
												''		-- OperationType
	
		if ( @iReturn <> 0 )
		begin
		  rollback transaction
		  print 'AmsSp_LogEventSummary_1 failed'
		  return -3
		end

		--Rename tag
		exec @iReturn = AmsSp_Operation_RenameDeviceTag_1 @nBlockKey,
														  @nTagAssignmentEventIdDay,
														  @nTagAssignmentEventIdFraction,
														  @DevCurrentTag, 
														  @sDevNewTag output,
														  @strAmsUserName,
														  @iComputerId,
														  @strEventSourceApplication,
														  @strEventReason,
														  @strFSUserName
		if ( @iReturn = 0 )
		begin
			set @sFinalAmsTag = @sDevNewTag
		end
		else
		begin
		  rollback transaction
		  print 'AmsSp_Operation_RenameDeviceTag_1 failed'
		  return -4
		end
	end
	else
	begin
		set @sFinalAmsTag = @sDevNewTag
	end

	--SCR AOEP00018726
	--Set HostPath and HostTag to blank if we have a decommission event.
	if (@nEventCategoryId = 73)
	begin
		Update DeviceLocation
		set HostPath = '', HostTag = '', IdentStatus = 0
		where BlockKey = @nBlockKey
	end

	--Operation is completed
	commit transaction
end

return @iReturn

GO

