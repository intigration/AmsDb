
---------------------------------------------------------------------------
--AmsSp_HostDevDef_ClearDeviceDefinitionInfo_2
--
--Delete host device from the given plant server network
--Used in Third Party PROFIBUS Network Identify PROFIBUS Device
--
-- Input:
--	@sPlantServerId	- Plant server Id
--	@sNetworkName	- Network name
--	@sHostDeviceId	- Host device Id
--
---- Output: - none
--
-- Returns -
--	 0 - successful.
--	-1 - general error.
--
-- Nghy Hong - 04/04/2012
--
CREATE PROCEDURE [dbo].[AmsSp_HostDevDef_ClearDeviceDefinitionInfo_2]
@sPlantServerId nvarchar(255),
@sNetworkName nvarchar(255),
@sHostDeviceId nvarchar(255)
AS
BEGIN
	set nocount on
	declare @nReturn int;
	set @nReturn = 0;

	begin try
	
		DELETE FROM  HostDeviceDefinition
		FROM  HostDeviceDefinition INNER JOIN
               NetworkInfo ON HostDeviceDefinition.NetworkInfoKey = NetworkInfo.NetworkInfoKey INNER JOIN
               PlantServer ON NetworkInfo.PlantServerKey = PlantServer.PlantServerKey
        WHERE HostDeviceDefinition.HostDeviceId = @sHostDeviceId
        AND NetworkInfo.NetworkName = @sNetworkName
        AND PlantServer.PlantServerId = @sPlantServerId;
		
	end try
	begin catch
		set @nReturn = -1 -- exception 
	end catch
	return @nReturn
END

GO

