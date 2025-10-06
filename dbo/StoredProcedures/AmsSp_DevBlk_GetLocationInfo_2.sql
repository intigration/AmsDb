-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetLocationInfo_2
--
-- Get the device-block location information.
--
-- Note: same as AmsSp_DevBlk_GetLocationInfo_1 except additional outputs
--
--
-- Inputs -
--	@nDeviceLevelBlockKey	int
--
-- Outputs -
--	@sPlantServerName	nvarchar(255)
--	@sAmsPath		nvarchar(1024)
--	@sHostPath		nvarchar(1024)
--	@sNetworkName		nvarchar(1024)
--	@sHostTag			nvarchar(255)
--	@nIdentStatus	int
--	@sNetworkId			nvarchar(255)
--	@sNetworkKind		nvarchar(1024)
--  @nSisStatus			int
--  @nLatencyFactor		smallint
--	
--
-- Returns -
--	0 - successful.
--	-1 - warning, DeviceLevelBlockKey not found.
--	-2 - Error, unable to get location information.
--
-- Joe Fisher - 2/13/2007
--

CREATE PROCEDURE AmsSp_DevBlk_GetLocationInfo_2
@nDeviceLevelBlockKey	int,
@sPlantServerName	nvarchar(255) output,
@sAmsPath		nvarchar(1024) output,
@sHostPath		nvarchar(1024) output,
@sNetworkName		nvarchar(1024) output,
@sHostTag		nvarchar(255) output,
@nIdentStatus		int output,
@sNetworkId		nvarchar(255) output,
@sNetworkKind		nvarchar(1024) output,
@nSisStatus			int output,
@nLatencyFactor		smallint output
AS
declare @iReturnVal int
set @iReturnVal = 0

set @sPlantServerName = ''
set @sAmsPath = ''
set @sHostPath = ''
set @sNetworkName = ''
set @sHostTag = ''
set @nIdentStatus = 0
set @sNetworkId = ''
set @sNetworkKind = ''
set @nSisStatus = 0
set @nLatencyFactor = 0

SELECT     @sPlantServerName = dbo.PlantServer.PlantServerId,
	   @sAmsPath =  dbo.DeviceLocation.AmsPath,
	   @sHostPath = dbo.DeviceLocation.HostPath,
	   @sNetworkName = dbo.NetworkInfo.NetworkName,
	   @sHostTag = dbo.DeviceLocation.HostTag,
	   @nIdentStatus = dbo.DeviceLocation.IdentStatus,
	   @sNetworkId = dbo.NetworkInfo.NetworkId,
	   @sNetworkKind = dbo.NetworkInfo.NetworkKindAsString,
	   @nSisStatus = dbo.DeviceLocation.SisStatus,
	   @nLatencyFactor = dbo.DeviceLocation.LatencyFactor
FROM         dbo.DeviceLocation with (nolock) INNER JOIN
          dbo.NetworkInfo with (nolock) ON dbo.DeviceLocation.NetworkInfoKey = dbo.NetworkInfo.NetworkInfoKey
		INNER JOIN dbo.PlantServer with (nolock) ON dbo.NetworkInfo.PlantServerKey = dbo.PlantServer.PlantServerKey
WHERE     (BlockKey = @nDeviceLevelBlockKey)

if (@@ROWCOUNT = 0)
begin
	set @iReturnVal = -1
end

if (@@ERROR <> 0)
begin
	set @iReturnVal = -2
end

return @iReturnVal

GO

