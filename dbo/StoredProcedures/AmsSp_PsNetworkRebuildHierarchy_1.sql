----------------------------------------------------------------------
-- AmsSp_PsNetworkRebuildHierarchy_1
--
-- Delete the network component associated with this plant server.
--
-- Inputs -
--	@sPlantServerName nvarchar(255)	plant server name.
--	@sNetworkId		  nvarchar(255)	network name- unique among the ps network group.
--
-- Outputs -
--	none.
--
-- Returns -
--	0 - successful.
--	-1 - Error, plant server not in database.
--	-2 - Error, unable to set devices' identStatus to Unknown.
--  -3 - Error, network component not in database.
--  -4 - Error, general error.
--
-- Joe Fisher 10/1/2003
--
CREATE PROCEDURE AmsSp_PsNetworkRebuildHierarchy_1
@sPlantServerName nvarchar(255),
@sNetworkId		  nvarchar(255)
AS
declare @nReturn int
declare @nPlantServerKey int
declare @nNetworkKey int
declare @nSPReturn int
declare @netCt int
set @nReturn = 0

set nocount on

exec @nSPReturn = AmsSp_GetPlantServerKey_1 @sPlantServerName, @nPlantServerKey output
if (@nSPReturn <> 0)
begin
	return -1	-- plant server not in database.
end

select @netCt = count(*) from NetworkInfo where (NetworkId = @sNetworkId) and (PlantServerKey = @nPlantServerKey)
if (@netCt = 1)
begin
	-- network present, set all devices' identStatus to 'Unknown'.
	select @nNetworkKey = NetworkInfoKey from NetworkInfo where (NetworkId = @sNetworkId) and (PlantServerKey = @nPlantServerKey)
	update DeviceLocation set IdentStatus = 0 where @nNetworkKey = NetworkInfoKey
	if (@@error <> 0)
	begin
		return -2	-- unable to set associated devices' identStatus.
	end
print 'Devices identStatus set to Unknown = ' + cast(@@rowcount as nvarchar(10))
end
else
begin
	-- network not present.
print 'network info not found.'
	return -3
end

return @nReturn

GO

