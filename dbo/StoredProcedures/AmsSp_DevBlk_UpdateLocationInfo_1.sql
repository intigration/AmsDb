-----------------------------------------------------------------------
-- AmsSp_DevBlk_UpdateLocationInfo_1
--
-- Update the device-block location information.
--
--
-- Inputs -
--	@nDeviceLevelBlockKey	int
--	@sPlantServerName	nvarchar(255)
--	@sAmsPath		nvarchar(1024)
--	@sHostPath		nvarchar(1024)
--	@sNetworkId		nvarchar(255)	-- note: this is the fms.ini network section header for this plantServer
--  @sHostTag		nvarchar(255)
--	@nSisStatus		int
--	@nLatencyFactor	smallint
--
-- Outputs -
--	@sOldPlantServerName	nvarchar(255)
--	@sOldAmsPath		nvarchar(1024)
--	@sOldHostPath		nvarchar(1024)
--	@sOldNetworkId		nvarchar(255)	-- note: this is the fms.ini network section header for this plantServer
--  @sOldHostTag		nvarchar(255)
--	@nOldSisStatus		int
--	@nOldLatencyFactor	smallint
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to update location information.
--
-- Joe Fisher - 8/14/2003
-- Joe Fisher - 4/25/2006 - took out GetAddId on plantServer and NetworkInfo.
-- Nghy Hong - 6/15/2006 - AOEP00019503 Update ScanList only if need to. (no longer applicable)
-- Joe Fisher - 2/13/2007 - added SisStatus and LatencyFactor update.

CREATE PROCEDURE AmsSp_DevBlk_UpdateLocationInfo_1
@nDeviceLevelBlockKey	int,
@sPlantServerName	nvarchar(255),
@sAmsPath		nvarchar(1024),
@sHostPath		nvarchar(1024),
@sNetworkId		nvarchar(255),	-- note: this is the fms.ini network section header for this plantServer
@sHostTag		nvarchar(255),
@nSisStatus		int,
@nLatencyFactor	smallint,
@sOldPlantServerName	nvarchar(255) output,
@sOldAmsPath		nvarchar(1024) output,
@sOldHostPath		nvarchar(1024) output,
@sOldNetworkId		nvarchar(255) output, -- note: this is the fms.ini network section header for this plantServer
@sOldHostTag		nvarchar(255) output,
@nOldSisStatus		int output,
@nOldLatencyFactor	smallint output
AS

declare @iReturnVal int
set @iReturnVal = 0
declare @nSpReturn int
declare @nPlantServerKey int
declare @nOldIdentStatus int
declare @nNetworkInfoKey int

set @sOldPlantServerName = ''
set @sOldAmsPath = ''
set @sOldNetworkId = ''
set @sOldHostPath = ''
set @sOldHostTag = ''
set @nOldIdentStatus = 0
set @nOldSisStatus = 0
set @nOldLatencyFactor = 0

-- get the current location information.
-- declare a couple of placeholders here.
declare @sOldNetworkName nvarchar(1024)
declare @sOldNetworkKind nvarchar(1024)
set @sOldNetworkName = ''
set @sOldNetworkKind = ''

exec @nSpReturn = AmsSp_DevBlk_GetLocationInfo_2 @nDeviceLevelBlockKey,
						@sOldPlantServerName output,
						@sOldAmsPath output,
						@sOldHostPath output,
						@sOldNetworkName output,
						@sOldHostTag output,
						@nOldIdentStatus output,
						@sOldNetworkId output,
						@sOldNetworkKind output,
						@nOldSisStatus output,
						@nOldLatencyFactor output
if (@nSpReturn <> 0)
begin
	-- device location info not found, add it.

	-- get database keys for the plantServer and network component.
	-- note: the network component is identified by plantServer's fms.ini section header
	exec @nSpReturn = AmsSp_NetworkInfo_GetDbKey_ByPsNetworkId_1 @sPlantServerName,
							@sNetworkId,
							@nPlantServerKey output,
							@nNetworkInfoKey output
	if (@nSpReturn <> 0)
	begin
		set @iReturnVal = -1
		return @iReturnVal
	end

	-- device location info not found, add it.
	-- make identStatus as 'Identified'.
	insert DeviceLocation with (rowlock) (BlockKey,
				PlantServerKey,
				NetworkInfoKey,
				AmsPath,
				HostPath,
				HostTag,
				IdentStatus,
				SisStatus,
				LatencyFactor)
		values (@nDeviceLevelBlockKey,
			@nPlantServerKey,
			@nNetworkInfoKey,
			@sAmsPath,
			@sHostPath,
			@sHostTag,
			1,				-- set the identStatus to identified.
			@nSisStatus,
			@nLatencyFactor)
	if @@error <> 0
	begin
		set @iReturnVal = -2
		return @iReturnVal
	end
end
else
begin
	-- location information found.
	-- now check to see if any of the information needs to be updated.
	if (@sPlantServerName <> @sOldPlantServerName) OR
	   (@sAmsPath <> @sOldAmsPath) OR
	   (@sHostPath <> @sOldHostPath) OR
	   (@sNetworkId <> @sOldNetworkId) OR
	   (@sHostTag <> @sOldHostTag) OR
	   (@nOldIdentStatus <> 1) OR
	   (@nSisStatus <> @nOldSisStatus) OR
	   (@nLatencyFactor <> @nOldLatencyFactor)
	begin
		-- something has changed about the location information.
		-- get database keys for the plantServer and network component.
		-- note: the network component is identified by plantServer's fms.ini section header
		exec @nSpReturn = AmsSp_NetworkInfo_GetDbKey_ByPsNetworkId_1 @sPlantServerName,
								@sNetworkId,
								@nPlantServerKey output,
								@nNetworkInfoKey output
	
		if (@nSpReturn <> 0)
		begin
			set @iReturnVal = -1
			return @iReturnVal
		end

		-- update the deviceLocation information.
		update DeviceLocation with (rowlock) set PlantServerKey = @nPlantServerKey,
					NetworkInfoKey = @nNetworkInfoKey,
					AmsPath = @sAmsPath,
					HostPath = @sHostPath,
					HostTag = @sHostTag,
					IdentStatus = 1,
					SisStatus = @nSisStatus,
					LatencyFactor = @nLatencyFactor
			where BlockKey = @nDeviceLevelBlockKey
		if @@error <> 0
		begin
			set @iReturnVal = -4
			return @iReturnVal
		end
	end
end

return @iReturnVal

GO

