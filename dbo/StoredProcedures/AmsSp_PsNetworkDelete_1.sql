----------------------------------------------------------------------
-- AmsSp_PsNetworkDelete_1
--
-- Delete the network component associated with this plant server.
--
-- Inputs -
--	@sPlantServerName nvarchar(255)	plant server name.
--	@sNetworkName	  nvarchar(255)	network name- unique among the ps network group.
--									this is the 'Name=' fms.ini value from the network
--									component.
--
-- Outputs -
--	none.
--
-- Returns -
--	0 - successful.
--	-1 - Error, plant server not in database.
--	-2 - Error, unable to set associated devices' identStatus to Unknown.
--	-3 - Error, unable to delete network info.
--  -4 - Error, network component not in database.
--  -5 - Error, general error.
--
-- Joe Fisher 10/1/2003
-- Joe Fisher 02/13/2006 -- added support for NetworkInfoProperty table.
--
CREATE PROCEDURE AmsSp_PsNetworkDelete_1
@sPlantServerName nvarchar(255),
@sNetworkName	  nvarchar(255)
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

select @netCt = count(*) from NetworkInfo where (NetworkName = @sNetworkName) and (PlantServerKey = @nPlantServerKey)
if (@netCt = 1)
begin
	-- network present, delete it.
	-- before we do, we need to set all devices' identStatus associated to this network to 'Unknown'
	-- plus we need to set their Network to the default 'unknown' network component.
	select @nNetworkKey = NetworkInfoKey from NetworkInfo where (NetworkName = @sNetworkName) and (PlantServerKey = @nPlantServerKey)
	update DeviceLocation set NetworkInfoKey = -1,
							  IdentStatus = 0
				where @nNetworkKey = NetworkInfoKey
	if (@@error <> 0)
	begin
		return -2	-- unable to set associated devices' identStatus.
	end
--print 'Devices identStatus set to Unknown = ' + cast(@@rowcount as nvarchar(10))

	-- update any NetworkInfo depedencies.
    -- HostDeviceDefinition dependancy --
	delete from HostDeviceDefinition where (NetworkInfoKey = @nNetworkKey)
	if (@@error <> 0)
	begin
		return -3	-- unable to delete HostDeviceDefinition data.
	end

	-- NetworkInfoProperty dependency --
	delete from NetworkInfoProperty where (NetworkInfoKey = @nNetworkKey)
	if (@@error <> 0)
	begin
		return -3	-- unable to delete NetworkInfoProperty data.
	end

	-- now go ahead and delete the network component.
	delete from NetworkInfo where (NetworkName = @sNetworkName) and (PlantServerKey = @nPlantServerKey)
	if (@@error <> 0)
	begin
		return -3	-- unable to delete.
	end
--print 'network info deleted.'
end
else
begin
	-- network not present.
print 'network info not found.'
	return -4
end

return @nReturn

GO

