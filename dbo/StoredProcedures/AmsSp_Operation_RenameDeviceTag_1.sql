-------------------------------------------------------------------------------
-- AmsSp_Operation_RenameDeviceTag_1 
--
-- Rename the device's tag.  
-- The following is the sequence of actions taken during the operation:
--		1.  Get the new tag into the database.
--		2.  Assign the new tag to the device and do tag re-assignment if needed.
--		3.  Assign test definition to the new assigned tag.
--			Rule of assigning test definition:  If the new tag does not exist in the database, 
--			device's current tag's test definition will be assigned to the new tag.
--			If the new tag does exist in the database, the test definition assignment will be 
--			whatever the new tag's test definition is.
--		4.  Update ExtBlockTagKey in RoutTags table to the new tag name.
--		5.  Update active alert list and et.al.
-- 
-- Inputs --
--	@nBlockKey int - Device level database block key
--  @nEventIdDay int - Day part of the rename event.
--  @nEventIdFraction int - Fraction part of the rename event.
--  @sDevCurrentTag nvarchar(255) - Device's current assigned tag
--  @sNewAmsTag nvarchar(255) - New tag to be assigned to the device.
--	@strAmsUserName nvarchar(256)
--		This is the Ams user name (i.e. the 'who') of the event.  
--		Needed for test definition assignment event.
--	@iComputerNameId int
--		This is the computer IP address (i.e. the 'where') of the event.
--		Needed for test definition assignment event.
--	@strEventSourceApplication nvarchar(256)
--		Some additional where for the event.
--		Needed for test definition assignment event.
--	@strEventReason nvarchar(1024)
--		This is the 'why' for the event.
--		Needed for test definition assignment event.
--	@strPSUserNameName nvarchar(255)
--		This is the File Server name.  Format is 'FS.<computerName>' and the
--		the client is responsible for formatting this up.
--		Needed for test definition assignment event.
--
-- Outputs --
--	None
--
-- Returns -
--	0 - successful
--  -1 - Empty tag(s) or general error
--  -3 - Device does not have current tag assignment error
--  -4 - Exec AmsSp_UnassignedTag_Get_1 stored procedure error
--  -5 - Exec AmsSp_Tag_Add_1 stored procedure error
--  -6 - Device-tag assignment error
--  -7 - Tag-test definition assignment error
--  -8 - Exec AmsSp_AssignNewTagTestDef_1 stored procedure error
--  -9 - Exec AmsSp_Operation_UpdateCalStatus_1 stored procedure error
--  -10 - Exec AmsSp_Operation_RenameDevice_1 stored procedure error
--
-- Author --
--	Nghy Hong
--	9/25/06
--
CREATE PROCEDURE AmsSp_Operation_RenameDeviceTag_1
@nBlockKey int,		--Device level BlockKey
@nEventIdDay as int,
@nEventIdFraction as int,
@sDevCurrentTag nvarchar(255),
@sNewAmsTag nvarchar(255) output,
@strAmsUserName nvarchar(50),
@iComputerId int,
@strEventSourceApplication nvarchar(50),
@strEventReason nvarchar(1024),
@strFSUserName nvarchar(255)
AS
declare @iReturn int
set @iReturn = 0	--Successful
declare @nTagExists int --0: exist, -1: not exist
set @nTagExists = -1
declare @nNewAmsTagExtBlockTagKey int
set @nNewAmsTagExtBlockTagKey = -1
declare @nDevCurrentExtBlockTagKey int
set @nDevCurrentExtBlockTagKey = -1

--Make sure we have tags to work with
if (len(@sDevCurrentTag) = 0 or len(@sNewAmsTag) = 0)
begin
	print 'Given tag(s) is/are empty'
	return -1
end

-- There is nothing to do if the new tag is same as device's current tag.
if (@sDevCurrentTag = @sNewAmsTag)
	return 0

--Make sure device currently assigned to the tag and get the ExtBlockTagKey
SELECT @nDevCurrentExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
FROM   ExtBlockTags INNER JOIN
 	   BlockAsgms ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey
WHERE (ExtBlockTags.ExtBlockTag = @sDevCurrentTag) AND  
	  (BlockAsgms.BlockKey = @nBlockKey) AND 
	  (BlockAsgms.EventIdDayOut = 49710) AND
	  (BlockAsgms.EventIdFractionOut = 0) 

if (@@rowcount <= 0)
begin
	print @sDevCurrentTag + ' is not currently assigned to the device'
	return -3
end

begin transaction

-----------------------------------------------------------------------------------------
--Getting the device's new tag into the database.
-----------------------------------------------------------------------------------------
--Make sure the new tag is not in the ExtBlockTags and NamedConfigs tables.
--If the new tag is in the NamedConfigs table or in the ExtBlockTags table 
--and currently assgined to device, then add a suffix of _nn to the tag where nn 
--is a number (example PT101_01).
declare @sAmsTagName nvarchar(255)
--Make sure the new tag has an unique tag name.
exec @iReturn = AmsSp_UnassignedTag_Get_1 @sNewAmsTag, @sAmsTagName output, @nTagExists output
if ( @iReturn <> 0 )
begin
	print 'exec AmsSp_UnassignedTag_Get_1 error'
	rollback transaction
	return -4
end
else
begin
	set @sNewAmsTag = @sAmsTagName
	print 'unassigned tag name is: ' + @sNewAmsTag
end

if ( @nTagExists = -1 ) --the tag does not exist
begin
	--add the new tag associated with (Default Field Device) TestDefinition
	--to the ExtBlockTags table
	exec @iReturn = AmsSp_Tag_Add_1 @sNewAmsTag, @nNewAmsTagExtBlockTagKey output
	if ( @iReturn <> 0 )
	begin
		print 'exec AmsSp_Tag_Add_1 error'
		rollback transaction
		return -5
	end
	else
	begin
		print 'ExtBlockTagKey is: ' + cast(@nNewAmsTagExtBlockTagKey as nvarchar(50))
	end
end  --the tag does not exist
else
begin  --the tag does exist
	-- Get the ExtBlockTagKey for the tag to be set as device's current tag assignment.
	SELECT @nNewAmsTagExtBlockTagKey = ExtBlockTagKey
	FROM 	ExtBlockTags 
	WHERE (ExtBlockTags.ExtBlockTag = @sNewAmsTag) 
	
	print 'ExtBlockTagKey is: ' + cast(@nNewAmsTagExtBlockTagKey as nvarchar(50))
end  --the tag does exist

-----------------------------------------------------------------------------------
--Do tag assignment
-----------------------------------------------------------------------------------
--Update the EventOut of the current device-tag assignment.
Update BlockAsgms
Set EventIdDayOut = @nEventIdDay, EventIdFractionOut = @nEventIdFraction
where (BlockAsgms.ExtBlockTagKey = @nDevCurrentExtBlockTagKey) AND
	  (BlockAsgms.BlockKey = @nBlockKey) AND
	  (BlockAsgms.EventIdDayOut = 49710) AND
	  (BlockAsgms.EventIdFractionOut = 0)

if ( @@rowcount = 0 )
begin 
	print 'Device does not have current tag assignment'
	rollback transaction
	return -3
end

--Assign this device to the new tag.
insert BlockAsgms(ExtBlockTagKey, 
		  BlockKey,
		  EventIdDayOut,
		  EventIdFractionOut,
		  EventIdDayIn,
		  EventIdFractionIn,
		  Archived)
values(@nNewAmsTagExtBlockTagKey, @nBlockKey, 49710, 0, @nEventIdDay, @nEventIdFraction, 0)

if @@ERROR!= 0 
begin
	print 'assign device to the new tag error'
	rollback transaction
	return -6
end

---------------------------------------------------------------------------------
--Do test definition assignment
---------------------------------------------------------------------------------
--If the tag to be renamed does not exist in the database, then we need to 
--associate it with the device's current tag's test definition.
--If the tag to be renamed to does exist, then we keep its test definition association.
declare @sThisTag nvarchar(255)
if ( @nTagExists = -1 ) -- -1 => The new tag that was inserted did not exist in the db in the past.
	set @sThisTag = @sDevCurrentTag
else
	set @sThisTag = @sNewAmsTag

declare @iThisTestDefId int
set @iThisTestDefId = -1
declare @sThisTestDefName nvarchar(255)

-- Get the test definition to be assigned to the new tag
SELECT @iThisTestDefId = TestDefinition.TestDefinitionId, 
	   @sThisTestDefName = TestDefinition.Name
FROM   ExtBlockTags INNER JOIN
	   TestDefinition ON ExtBlockTags.TestDefinitionId = TestDefinition.TestDefinitionId
WHERE  (ExtBlockTags.ExtBlockTag = @sThisTag)

if (@@rowcount = 0)
begin
	print @sThisTag + ' is not associated with a test definition'
	rollback transaction
	return -7
end
else
begin
	-- Assign the new tag to the previous tag's test definition.

	-- check to see if this extBlockTag is currently assigned to a testDefinition.
	declare @nRecCt int
	select @nRecCt = count(*) from TestDefAsgms
	where (ExtBlockTagKey = @nNewAmsTagExtBlockTagKey) and
			(EventIdDayOut = 49710) and
			(EventIdFractionOut = 0)
	if (@nRecCt = 0)
	begin
		declare @nTestDefAssignmentEventIdDay int
		declare @nTestDefAssignmentEventIdFraction int
		exec @iReturn = AmsSp_LogEventSummary_1	'NO_EVENTTIME',
												@strAmsUserName,
												@iComputerId,
												-1,		--event not associated with device.
												0,		--EventCode (always 0)
												@strEventSourceApplication,
												2,		--Event type = calibration
												49,		--Event Category =  Change Test Scheme assignment
												@strEventReason,
												0,		--OtherBufLen
												'',		--Other
												0,		--Archived
												@strFSUserName,
												@nTestDefAssignmentEventIdDay output,
												@nTestDefAssignmentEventIdFraction output,
												'',		-- AlertId,
												'',		-- AlertTypeUid,
												'',		-- MoreDetail,
												''		-- OperationType
		if (@iReturn <> 0)
		begin
			print 'exec AmsSp_LogEventSummary_1 error- ' + convert(nvarchar(10), @iReturn)
			rollback transaction
			return -8
		end

		exec @iReturn = AmsSp_AssignNewTagTestDef_1 @sNewAmsTag, @sThisTestDefName, @nTestDefAssignmentEventIdDay, @nTestDefAssignmentEventIdFraction
		if (@iReturn <> 0)
		begin
			print 'exec AmsSp_AssignNewTagTestDef_1 error- ' + convert(nvarchar(10), @iReturn)
			rollback transaction
			return -8
		end
	end
end

------------------------------------------------------------------------------------
--Update RoutTags with the new tag name
------------------------------------------------------------------------------------
UPDATE RouteTags
SET    ExtBlockTagKey = @nNewAmsTagExtBlockTagKey
WHERE  (ExtBlockTagKey = @nDevCurrentExtBlockTagKey)  

UPDATE RouteTags
SET    PreviousExtTagKeyInRoute = @nNewAmsTagExtBlockTagKey
WHERE  (PreviousExtTagKeyInRoute = @nDevCurrentExtBlockTagKey)  

UPDATE RouteTags
SET    NextExtTagKeyInRoute = @nNewAmsTagExtBlockTagKey
WHERE  (NextExtTagKeyInRoute = @nDevCurrentExtBlockTagKey) 

-------------------------------------------------------------------------------------
--Update calibration status to new test definition
-------------------------------------------------------------------------------------
exec @iReturn = AmsSp_Operation_UpdateCalStatus_1 @nBlockKey
if (@iReturn <> 0)
begin
	print 'exec AmsSp_Operation_UpdateCalStatus_1 error- ' + convert(nvarchar(10), @iReturn)
	rollback transaction
	return -9
end

------------------------------------------------------------------------------------
--Update active alert list and et.al.
------------------------------------------------------------------------------------
exec @iReturn = AmsSp_Operation_RenameDevice_1 @nBlockKey
if (@iReturn <> 0)
begin
	print 'exec AmsSp_Operation_RenameDevice_1 error- ' + convert(nvarchar(10), @iReturn)
	rollback transaction
	return -10
end

commit transaction
return @iReturn

GO

