-----------------------------------------------------------------------
-- AmsSp_Reconcile_RemovePlantServer_1
--
-- During Reconciliation, this removes the alerts, devices, and network info from the database.
--
-- Inputs -
--	@nPlantServerKey	int
--
-- Outputs -
--	@nDeletedDeviceMonitorListItems	int
--  @nDeletedDeviceLocationItems int
--  @nDeletedNetworkItems int
--
-- Returns -
--	0 - successful.
--	non-zero - error.
--
-- James Kramer 9/29/2008
-- SCR AOEP00027934

CREATE PROCEDURE AmsSp_Reconcile_RemovePlantServer_1
@nPlantServerKey	int,
@nDeletedDeviceMonitorListItems	int output,
@nDeletedDeviceLocationItems int output,
@nDeletedNetworkItems int output
AS
declare @iReturnVal int
declare @nAlerts int

set @iReturnVal = 0

set @nDeletedDeviceMonitorListItems = 0
set @nDeletedDeviceLocationItems = 0
set @nDeletedNetworkItems = 0
set @nAlerts = 0

begin try
	-- Remove devices from AlertFilterForDevice table for the given plant server
	DELETE AlertFilterForDevice 
	FROM AlertFilterForDevice INNER JOIN DeviceLocation
	ON AlertFilterForDevice.BlockKey = DeviceLocation.BlockKey
	WHERE (DeviceLocation.PlantServerKey = @nPlantServerKey)

    -- Remove devices from DeviceMonitorList table for the given plant server
    DELETE DeviceMonitorList
    FROM DeviceMonitorList INNER JOIN DeviceLocation
    ON DeviceMonitorList.BlockKey = DeviceLocation.BlockKey
    WHERE (DeviceLocation.PlantServerKey = @nPlantServerKey)

	set @nDeletedDeviceMonitorListItems = @@ROWCOUNT

    -- Remove devices from AlertList table for the given plant server
    DELETE AlertList
    FROM AlertList INNER JOIN DeviceLocation
    ON AlertList.BlockKey = DeviceLocation.BlockKey
    WHERE (DeviceLocation.PlantServerKey = @nPlantServerKey)

	set @nAlerts = @@ROWCOUNT

    -- Remove properties from StationProperty table for the given plant server
    DELETE StationProperty 
    FROM StationProperty 
    WHERE (PlantServerKey = @nPlantServerKey)
                    
    -- Remove devices from DeviceLocation table for the given plant server
    DELETE FROM DeviceLocation WHERE (PlantServerKey = @nPlantServerKey)

	set @nDeletedDeviceLocationItems = @@ROWCOUNT
	
	-- Remove the given plant server from the HostDeviceDefinition
	DELETE HostDeviceDefinition FROM HostDeviceDefinition INNER JOIN NetworkInfo ON NetworkInfo.NetworkInfoKey = HostDeviceDefinition.NetworkInfoKey
	WHERE NetworkInfo.PlantServerKey = @nPlantServerKey

    -- Remove the given plant server from the NetWorkInfoProperty table
    DELETE NetworkInfoProperty FROM NetworkInfoProperty INNER JOIN NetworkInfo ON NetworkInfo.NetworkInfoKey = NetworkInfoProperty.NetworkInfoKey
	WHERE NetworkInfo.PlantServerKey = @nPlantServerKey

    -- Remove the given plant server from the NetWorkInfo table
    DELETE FROM NetworkInfo WHERE (PlantServerKey = @nPlantServerKey)

	set @nDeletedNetworkItems = @@ROWCOUNT

    -- Remove plant server from PlantServer table
    DELETE FROM PlantServer WHERE (PlantServerKey = @nPlantServerKey)

	if (@nAlerts > 0)
	begin
		exec AmsSp_NotifyQ_Push_1 6, ''    -- 6 - signal that the alert list is changed.
	end

	if (@nDeletedDeviceMonitorListItems > 0)
	begin
		exec AmsSp_NotifyQ_Push_1 7, ''		-- 7 - signal that the monitor list is changed.
	end

end try
begin catch
	set @iReturnVal = -1
end catch

return @iReturnVal

GO

