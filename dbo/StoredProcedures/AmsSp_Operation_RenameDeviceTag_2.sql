----------------------------------------------------------------------
-- AmsSp_Operation_RenameDeviceTag_2
--
--
-- Rename the device's tag.  
-- The following is the sequence of actions taken during the operation:
--		1.  Get the new tag into the database.
--		2.  Assign the new tag to the device and do tag re-assignment if needed.
--		3.  Assign test definition to the new assigned tag.
--		4.  Update ExtBlockTagKey in RoutTags table to the new tag name.
--		5.  Update active alert list and et.al.
-- 
-- Inputs --
--  @sDevCurrentTag nvarchar(255) - Device's current assigned tag
--  @sDevNewTag nvarchar(255) - New tag to be assigned to the device.
--	@sAmsUserName nvarchar(255)
--		This is the Ams user name (i.e. the 'who') of the event. 
--	@iComputerId int
--		This is the computer IP address (i.e. the 'where') of the event.
--	@sEventSourceApplication nvarchar(256)
--		Some additional where for the event.
--	@sEventReason nvarchar(1024)
--		This is the 'why' for the event.
--	@sFSUserName nvarchar(255)
--		This is the File Server name.  Format is 'FS.<computerName>' and the
--		the client is responsible for formatting this up.
--	@nMakeNewTagUnique int
--		1 = true otherwise false.
--
--		If @nMakeNewTagUnique = 1 
--			A suffix of _nn (where nn is a number (example PT101_01))
--			is added to the device's new tag if the new tag is currently assigned to other device.
--
--		If @nMakeNewTagUnique != 1 
--			Return code of -2 is returned to indicate device-tag assignment failure
--			due to the provided new tag is currently assigned to another device in the system. 
--	
-- Outputs --
--	None
--
-- Returns -
--	 0 - successful
--  -1 - general error
--	-2 - New tag name is currently assigned to another device
--  -3 - Execution of AmsSp_IsTagAssigned_1 failed
--  -4 - Generation of tag assignment event failed
--  -5 - Renaming device tag failed
--
-- Nghy Hong 2/01/2012
--
CREATE PROCEDURE AmsSp_Operation_RenameDeviceTag_2
@sDevCurrentTag nvarchar(255),
@sDevNewTag nvarchar(255),
@sAmsUserName nvarchar(255),
@iComputerId int,
@sEventSourceApplication nvarchar(255),
@sEventReason nvarchar(1024),
@sFSUserName nvarchar(255),
@nMakeNewTagUnique int
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY
	begin transaction
	
	--Get device information by tag
	declare @iBlockKey int;
	select @iBlockKey = BlockKey from  AmsVw_BlockTags where AmsTag = @sDevCurrentTag
	
	--Make new tag name unique or not
	if (@nMakeNewTagUnique <> 1)
	begin
		declare @nCurrentlyAssigned int;
		exec @nReturn = AmsSp_IsTagAssigned_1 @sDevNewTag, @nCurrentlyAssigned output
		
		if (@nReturn = 0)
		begin
			--Check if the new tag is currently assigned to a device
			if (@nCurrentlyAssigned = 1)
				set @nReturn = -2; -- New tag name is currently assigned to another device
		end
		else
			set @nReturn = -3; --Execution of AmsSp_IsTagAssigned_1 failed
	end
	
	if (@nReturn = 0) 
	begin
		--Generate an event to do the tag assignment.
		declare @nTagAssignmentEventIdDay int
		declare @nTagAssignmentEventIdFraction int
		exec @nReturn = AmsSp_LogEventSummary_1	'NO_EVENTTIME',
												@sAmsUserName,
												@iComputerId,
												@iBlockKey,	--Device level BlockKey
												0,		--EventCode (always 0)
												@sEventSourceApplication,
												1,		--Event type = Config change 
												1,		--Event category = Change performed by AMS Device Manager
												@sEventReason,
												0,		--OtherBufLen
												'',		--Other
												0,		--Archived
												@sFSUserName,
												@nTagAssignmentEventIdDay output,
												@nTagAssignmentEventIdFraction output,
												'',		-- AlertId,
												'',		-- AlertTypeUid,
												'',		-- MoreDetail,
												''		-- OperationType
												
		if (@nReturn <> 0)
			set @nReturn = -4; --Generation of tag assignment event failed										
	end
	
	if (@nReturn = 0) 
	begin		
		--Rename tag
		exec @nReturn = AmsSp_Operation_RenameDeviceTag_1 @iBlockKey,
														  @nTagAssignmentEventIdDay,
														  @nTagAssignmentEventIdFraction,
														  @sDevCurrentTag, 
														  @sDevNewTag output,
														  @sAmsUserName,
														  @iComputerId,
														  @sEventSourceApplication,
														  @sEventReason,
														  @sFSUserName
												
		if (@nReturn <> 0)
			set @nReturn = -5; --Renaming device tag failed

	end

	if  (@nReturn = 0)
	begin
		if @@trancount > 0
			commit transaction;
	end
	else
	begin
		if @@trancount > 0
			rollback transaction;
	end
		
END TRY
BEGIN CATCH
	set @nReturn = -1;
	if @@trancount > 0
		rollback transaction;
END CATCH

RETURN @nReturn;

GO

