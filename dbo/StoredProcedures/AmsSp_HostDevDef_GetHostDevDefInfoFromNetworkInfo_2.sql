---------------------------------------------------------------------------
--AmsSp_HostDevDef_GetHostDevDefInfoFromNetworkInfo_2
--
--Get host device from the given plant server network
--Used in Third Party PROFIBUS Network Identify PROFIBUS Device
--
-- Input:
--	@sPlantServerId	   - Plant server ID
--	@sNetworkName	   - Network name
--	@sHostDeviceId	   - Host device ID
--  @nGSDId			   - GSD Id
--
---- Output:
--  @sDeviceDefinition - Device Definition
--
-- Returns -
--	 0 - successful.
--	-1 - general error.
--  -2 - invalid plant server network
--  -3 - device not in table or listed multiple times
--
-- Angie Victoriano - 04/24/2012
CREATE PROCEDURE [dbo].[AmsSp_HostDevDef_GetHostDevDefInfoFromNetworkInfo_2]
@sPlantServerId nvarchar(255),
@sNetworkName nvarchar(255),
@sHostDeviceId nvarchar(255),
@nGSDId int, 
@sDeviceDefinition nvarchar(255) output
AS
BEGIN
	set nocount on
	declare @nReturn int;
	set @nReturn = 0;

	begin try
		declare @nNetworkInfoKey int;
		set @nNetworkInfoKey = -1;
		-- Get the NetworkKey
		SELECT @nNetworkInfoKey = NetworkInfo.NetworkInfoKey
		FROM  NetworkInfo INNER JOIN
               PlantServer ON NetworkInfo.PlantServerKey = PlantServer.PlantServerKey
		WHERE (NetworkInfo.NetworkName = @sNetworkName) AND (PlantServer.PlantServerId = @sPlantServerId)
	
		if (@nNetworkInfoKey = -1)
		begin
			set @nReturn = -2;
		end
		else
		begin
			select @sDeviceDefinition = DeviceDefinition from HostDeviceDefinition
			where (NetworkInfoKey = @nNetworkInfoKey) and (HostDeviceId = @sHostDeviceId) and (GSDId = @nGSDId)
			if (@@ROWCOUNT <> 1)
			begin
				set @nReturn = -3 -- failed - device not in table or listed multiple times
			end
		end
	end try
	begin catch
		set @nReturn = -1;
	end catch
	return @nReturn
END

GO

