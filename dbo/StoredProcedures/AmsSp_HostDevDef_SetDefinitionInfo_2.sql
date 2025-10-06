---------------------------------------------------------------------------
--AmsSp_HostDevDef_SetDefinitionInfo_2
--
--Add host device to the given plant server network
--Used in Third Party PROFIBUS Network Identify PROFIBUS Device
--
-- Input:
--	@sPlantServerId	   - Plant server ID
--	@sNetworkName	   - Network name
--	@sHostDeviceId	   - Host device ID
--  @sDeviceDefinition - Device Definition
--  @nGSDId			   - GSD Id
--
---- Output: - none
--
-- Returns -
--	 0 - successful.
--	-1 - general error.
--  -2 - invalid plant server network
--
-- Nghy Hong - 04/04/2012
CREATE PROCEDURE [dbo].[AmsSp_HostDevDef_SetDefinitionInfo_2]
@sPlantServerId nvarchar(255),
@sNetworkName nvarchar(255),
@sHostDeviceId nvarchar(255),
@sDeviceDefinition nvarchar(255),
@nGSDId int
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
			-- see if the device is already define - if so update
			if (Exists(select * from HostDeviceDefinition where NetworkInfoKey = @nNetworkInfoKey and HostDeviceId = @sHostDeviceId))
			begin
				update HostDeviceDefinition
				set DeviceDefinition = @sDeviceDefinition, GSDId = @nGSDId
				where NetworkInfoKey = @nNetworkInfoKey and HostDeviceId = @sHostDeviceId
			end
			-- see if device definition is already in the database - if so update
			else if (Exists(select * from HostDeviceDefinition where NetworkInfoKey = @nNetworkInfoKey and DeviceDefinition = @sDeviceDefinition))
			begin
				update HostDeviceDefinition
				set HostDeviceId = @sHostDeviceId, GSDId = @nGSDId
				where NetworkInfoKey = @nNetworkInfoKey and DeviceDefinition = @sDeviceDefinition
			end
			else -- otherwise add new entry
			begin
				insert into HostDeviceDefinition 
				(NetworkInfoKey, HostDeviceId, DeviceDefinition, GSDId) 
				values (@nNetworkInfoKey, @sHostDeviceId, @sDeviceDefinition, @nGSDId)
			end
		end 
		
	end try
	begin catch
		set @nReturn = -1;
	end catch
	return @nReturn
END

GO

