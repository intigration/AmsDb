-----------------------------------------------------------------------
-- AmsSp_Devices_GetAddKey_2
--
-- Get device-block key along with other stuff.
-- If not present then go ahead and add it.
--
-- Adding involves the following --
--	*  Add device and set default values (ie. calStatus, etc.)
--	*  Assign the suggested tag to the AmsTag assignment.
--	*  Generate events for the device add and the tag assignment.
--
--
-- Inputs -
--	@sManufacturerName	nvarchar(255)
--	@sProtocolName		nvarchar(255)
--	@sDeviceTypeName	nvarchar(255)
--	@sDeviceRevisionName	nvarchar(255)
--	@sIdentifier		nvarchar(255)
--	@nProtocolRev		int
--	@sSuggestedAmsTag	nvarchar(255)
--	@sEventAppName		nvarchar(255)
--	@sEventComputerId	nvarchar(255)
--	@sEventAmsUserName	nvarchar(255)
--  @nMaxDevicesLicensed	int
--
-- Outputs -
--	@nDeviceBlockKey 	int
--	@bDeviceAdded		int	device added = 1 else 0.
--	@bTagNameChanged	int	tag name changed = 1 else 0.
--	@sFinalAmsTag		nvarchar(255)
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get DeviceKey.
--	-2 - Error, unable to find device type info.
--	-3 - Error, unable to add device.
--	-4 - Error, unable to update blocks table.
-- 	-5 - Error, unable to update calstatus table.
--	-6 - Error, unable to assign AmsTag.
--	-7 - Error, unable to log 'Device identified' event.
--	-8 - Error, max device licensed count exceeded.
--
-- Joe Fisher - 8/14/2003
-- Nghy Hong	- 7/29/2008 (AOEP00025856) include protocol rev into consideration when add device to the DB.

CREATE PROCEDURE AmsSp_Devices_GetAddKey_2
@sManufacturerName	nvarchar(255),
@sProtocolName		nvarchar(255),
@sDeviceTypeName	nvarchar(255),
@sDeviceRevisionName	nvarchar(255),
@sIdentifier		nvarchar(255),
@nProtocolRev		int,
@sSuggestedAmsTag	nvarchar(255),
@sEventAppName		nvarchar(255),
@sEventComputerId	nvarchar(255),
@sEventAmsUserName	nvarchar(255),
@nMaxDevicesLicensed	int,
@nDeviceBlockKey 	int OUTPUT,
@bDeviceAdded		int OUTPUT,
@bTagNameChanged	int OUTPUT,
@sFinalAmsTag		nvarchar(255) OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0
declare @nSpReturn int

set @nDeviceBlockKey = -999
set @bDeviceAdded = 0
set @bTagNameChanged = 0
set @sFinalAmsTag = ''

-- get device-level block key and tag if present.
-- if device is present this will get us in and out of this quick.
if @sProtocolName = 'HART'
    begin --don't check the device revision on HART dev. Do check now!!!
	SELECT	@sFinalAmsTag = AmsTag,  @nDeviceBlockKey = BlockKey
	FROM    dbo.AmsVw_BlockTags with (nolock)
	WHERE  	(Manufacturer = @sManufacturerName) AND
		(Protocol = @sProtocolName) AND
		(ProtocolRevision = @nProtocolRev) AND
		(DeviceTypeName = @sDeviceTypeName) AND
		(SerialNumber = @sIdentifier) AND
		(DeviceRevisionName = @sDeviceRevisionName) AND
		(BlockIndex = 0)
    end
else
    begin
	SELECT	@sFinalAmsTag = AmsTag,  @nDeviceBlockKey = BlockKey
	FROM    dbo.AmsVw_BlockTags with (nolock)
	WHERE  	(Manufacturer = @sManufacturerName) AND
		(Protocol = @sProtocolName) AND
		(DeviceTypeName = @sDeviceTypeName) AND
		(DeviceRevisionName = @sDeviceRevisionName) AND
		(SerialNumber = @sIdentifier) AND
		(BlockIndex = 0)
    end 

if (@@rowcount > 0)
begin
	-- device found and we have the devBlockKey- get out.
	return 0
end
else
begin
	--Device not found, add it
	--
	-- indicate to SQL this is a start of a transaction- if we have problems
	-- along the way be sure to rollback the transaction.  If we succeed in
	-- adding this device be sure to commit the transaction.
	Begin Transaction

	-- check to see if we have exceeded license count.
	declare @nDeviceCount int
	exec @nDeviceCount = AmsSp_GetDeviceCount_1
	if (@nDeviceCount >= @nMaxDevicesLicensed)
	begin
		set @iReturnVal = -8
		goto PROBLEM
	end

	-- get the deviceRevision key for this device type.
	declare @nAmsDevRevId int
	SELECT     @nAmsDevRevId = dbo.DeviceRevisions.AmsDevRevId
	FROM       dbo.Manufacturers with (nolock) INNER JOIN
	           dbo.MfrProtocols with (nolock) ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
	           dbo.DeviceProtocols with (nolock) ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
	           dbo.DeviceTypes with (nolock) ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
	           dbo.DeviceRevisions with (nolock) ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId INNER JOIN
			   dbo.NamedConfigs with (nolock) ON dbo.DeviceRevisions.AmsDevRevId = dbo.NamedConfigs.AmsDevRevId
	WHERE	(dbo.Manufacturers.Name = @sManufacturerName) AND
		(dbo.DeviceProtocols.Name = @sProtocolName) AND
		(dbo.DeviceTypes.Name = @sDeviceTypeName) AND
		(dbo.DeviceRevisions.Name = @sDeviceRevisionName) AND
		(dbo.NamedConfigs.UniversalId = @nProtocolRev)

	if (@@rowcount = 0)
	begin
		-- Device type not found based on Mfr name, device type name, device rev name and protocol rev,
		-- this must be adding device on the fly where protocol rev is not available in the dabatase.
		-- To support adding device on the fly, the device is allowed to come in 
		-- based on Mfr name, device type name, device rev name
		SELECT     @nAmsDevRevId = dbo.DeviceRevisions.AmsDevRevId
		FROM       dbo.Manufacturers with (nolock) INNER JOIN
				   dbo.MfrProtocols with (nolock) ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
				   dbo.DeviceProtocols with (nolock) ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
				   dbo.DeviceTypes with (nolock) ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
				   dbo.DeviceRevisions with (nolock) ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId
		WHERE	(dbo.Manufacturers.Name = @sManufacturerName) AND
			(dbo.DeviceProtocols.Name = @sProtocolName) AND
			(dbo.DeviceTypes.Name = @sDeviceTypeName) AND
			(dbo.DeviceRevisions.Name = @sDeviceRevisionName)
	
		if (@@rowcount = 0)
		begin
			-- serious problems here !!
			-- could not find the device type info
			set @iReturnVal = -2
			goto PROBLEM
		end
	end

	-- Now go ahead and add the device.
	--
	-- get the next DeviceKey
	declare @nNewDeviceKey int
	select @nNewDeviceKey = max(DeviceKey) + 1 from Devices

	-- generate a AmsDeviceId- aka GUID
	declare @uidAmsDeviceId uniqueidentifier
	set @uidAmsDeviceId = NEWID()
	declare @sAmsDeviceId nvarchar(255)
	set @sAmsDeviceId = CONVERT(nvarchar(255), @uidAmsDeviceId)

	-- set the device's initial disposition
	declare @nDispositionId smallint
	set @nDispositionId = 2	-- 2 = Spare

	-- go ahead and set the (useless) AmsDevTag to the supplied tag.
	declare @sAmsDevTag nvarchar(255)
	set @sAmsDevTag = @sSuggestedAmsTag
	declare @sProtocolRev nvarchar(50)
	set @sProtocolRev = cast(@nProtocolRev as nvarchar(50))

	-- add Device to db
	insert Devices with (rowlock) (DeviceKey, 
			AmsDevRevId,
			AmsDeviceId,
			Identifier,
			ProtocolRevision,
			DispositionId,
			AmsDeviceTag)
		values (@nNewDeviceKey,
			@nAmsDevRevId,
			@sAmsDeviceId,
			@sIdentifier,
			@sProtocolRev,
			@nDispositionId,
			@sAmsDevTag)

	if (@@ERROR <> 0)
	begin
		-- problems adding device !!
		set @iReturnVal = -3
		goto PROBLEM
	end

	-- set other 'extended' device properties.
	--
	-- we need to establish the associated block(s).
	-- set the device-level block, all devices have one and only one of these.
	declare @nDevLevelBlockKey int
	select @nDevLevelBlockKey = max(BlockKey) + 1 from Blocks
	insert Blocks with (rowlock) (BlockKey,
			DeviceKey,
			BlockIndex,
			DispositionId,
			BlockType)
		values (@nDevLevelBlockKey,
			@nNewDeviceKey,
			0,
			0,
			'')
	if @@error <> 0 
	begin
		-- problems updating the Blocks table.
		set @iReturnVal = -4
		goto PROBLEM
	end

	-- if we have a multi-block type device (eg. 'FF') then we need to obtain
	-- the list of blocks from the device-type 'characteristics' type template
	-- and add to the blocks table.
	declare aCursor cursor for
		SELECT     dbo.NamedConfigBlocks.BlockIndex as BlockIndex,
			   dbo.NamedConfigBlocks.BlockType as BlockType
		FROM       dbo.NamedConfigs with (nolock) INNER JOIN
                      	   dbo.NamedConfigBlocks with (nolock) ON dbo.NamedConfigs.ConfigKey = dbo.NamedConfigBlocks.ConfigKey
		WHERE     (dbo.NamedConfigs.AmsDevRevId = @nAmsDevRevId) AND 
			  (dbo.NamedConfigs.ConfigType = 'C') AND 
			  (dbo.NamedConfigBlocks.BlockIndex <> 0)
	declare @nBlkIdx int
	declare @sBlkType nvarchar(1)
	declare @nBlkKey int
	open aCursor
	fetch next from aCursor into @nBlkIdx, @sBlkType
	while (@@fetch_status = 0)
	begin
		select @nBlkKey = max(BlockKey) + 1 from Blocks
		insert Blocks with (rowlock) (BlockKey,
				DeviceKey,
				BlockIndex,
				DispositionId,
				BlockType)
			values (@nBlkKey,
				@nNewDeviceKey,
				@nBlkIdx,
				0,
				@sBlkType)
		fetch next from aCursor into @nBlkIdx, @sBlkType
	end
	close aCursor
	deallocate aCursor

	-- update CalStatus table
	insert CalStatus with (rowlock) (DeviceKey, 
			  DevLastCalibrationDay,
			  DevLastCalibrationFraction,
			  DevNextCalibrationDueDay, 
			  DevNextCalibrationDueFraction,
			  DevPassedLastCalibration)
		values (@nNewDeviceKey, 0, 0,0, 0, '')
	if @@error <> 0 
	begin
		-- problems updating the calStatus stuff.
		set @iReturnVal = -5
		goto PROBLEM
	end

	-- generate the device added event.
	declare @nEventIdDay int
	declare @nEventIdFraction int
	-- log the event.
	-- NOTE: the eventID will be generated from the eventDateTime.
	declare @sEventDateTime nvarchar(50)
	-- let the logEventSummary assign the current time. 
	set @sEventDateTime = 'NO_EVENTTIME'
	declare @nComputerId int
	set @nComputerId = cast(@sEventComputerId as int)
	exec @nSPReturn = AmsSp_LogEventSummary_1  @sEventDateTime,
						@sEventAmsUserName,
						@nComputerId,
						@nDevLevelBlockKey,
						0, -- eventCode
						@sEventAppName,
						1, -- eventTypeId --DBW_ET_CHANGE
						1, -- eventCategoryId - --DBW_ECAT_CHANGE_BY_FMS --'change performed by AMS'
						'Device identified',
						0, '',	-- otherBufLen and otherBuf
						0,		-- archived
						@sEventAmsUserName,
						@nEventIdDay output,
						@nEventIdFraction output,
						'',		-- alertId,
						'',		-- alertType,
						'',		-- moreDetail,
						''		-- operationType
	if @nSPReturn = -1
	begin
		set @iReturnVal = -7
		goto PROBLEM
	end
	
	-- assign the AmsTag to the device-block level with the same event.
	exec @nSpReturn = AmsSp_AssignDevTag_1 @nDevLevelBlockKey,
				  @sSuggestedAmsTag,
				  @nEventIdDay,
				  @nEventIdFraction,
				  @sFinalAmsTag output
	if (@nSpReturn <> 0)
	begin
		set @iReturnVal = -6
		goto PROBLEM
	end
	-- we have successful assignment.
	if (@sFinalAmsTag <> @sSuggestedAmsTag)
	begin
		set @bTagNameChanged = 1
	end

	-- we have made it- we have added and assigned the device.
	set @nDeviceBlockKey = @nDevLevelBlockKey

	-- indicate to caller that we added the device
	set @bDeviceAdded = 1
end

-- successful device update; indicate that transaction is complete.
Commit Transaction
return 0

PROBLEM:
Print 'Unable to complete AmsSp_Devices_GetAddKey_2; returnVal= ' + cast(@iReturnVal as nvarchar(5))
-- be sure to rollback any changes we have made.
Rollback Transaction
return @iReturnVal

GO

