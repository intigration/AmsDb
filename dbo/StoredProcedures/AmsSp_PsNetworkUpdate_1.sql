----------------------------------------------------------------------
-- AmsSp_PsNetworkUpdate_1
--
-- Update the plant server network component with that supplied.
-- If the network component is not present in the database then it is
-- added.
--
-- Note: the plantServer name is added if it isn't present.
--
-- Inputs -
--	@sPlantServerName nvarchar(255)	plant server name.
--	@sNetworkId		  nvarchar(255)	network's fms.ini section name.
--  @sNetworkName	  nvarchar(1024)	network's fms.ini 'Name=' value, unique amongst plantServers.
--	@sNetworkKindAsString	  nvarchar(1024)	network kind (as string.)
--
-- Outputs -
--	none.
--
-- Returns -
--	0 - successful.
--	-1 - Error, problems with getting plantServer key.
--  -2 - Error, unable to update network info.
--	-3 - Error, unable to add network info.
--  -4 - Error, general error.
--
-- Joe Fisher 10/1/2003
--
CREATE PROCEDURE AmsSp_PsNetworkUpdate_1
@sPlantServerName nvarchar(255),
@sNetworkId		  nvarchar(255),
@sNetworkName	  nvarchar(1024),
@sNetworkKindAsString	  nvarchar(1024)
AS
declare @nReturn int
declare @nPlantServerKey int
declare @nNetworkKey int
declare @nSPReturn int
declare @netCt int
set @nReturn = 0

set nocount on

-- make sure the plantServer name is in the database, add it if it isn't.
exec @nSPReturn = AmsSp_GetAdd_PlantServer_1 @sPlantServerName, @nPlantServerKey output
if (@nSPReturn <> 0)
begin
	return -1	-- problems with getting plantServer key.
end

select @netCt = count(*) from NetworkInfo where (NetworkName = @sNetworkName) and (PlantServerKey = @nPlantServerKey)
if (@netCt = 1)
begin
	-- network present, update it.
	update NetworkInfo set NetworkId = @sNetworkId,
						   NetworkKindAsString = @sNetworkKindAsString
		where (NetworkName = @sNetworkName) and (PlantServerKey = @nPlantServerKey)
	if (@@error <> 0)
	begin
		return -2	-- unable to update.
	end

-- AOEP00023876 needs to regresses ComQa23847 because it dose not handle all cases
	-- ComQa23847.
	-- if network kind is a 'HART Modem' then set all devices' identStatus to 'unknown'
	if (@sNetworkKindAsString = 'HART Modem')
	begin
		SELECT     @nNetworkKey = NetworkInfoKey
		from       NetworkInfo
		WHERE     (PlantServerKey = @nPlantServerKey) AND (NetworkName = @sNetworkName)

		update DeviceLocation set IdentStatus = 0
			where (PlantServerKey = @nPlantServerKey) and (NetworkInfoKey = @nNetworkKey)
		if (@@error <> 0)
		begin
			return -2	-- unable to update.
		end
    end

--print 'network info updated.'
end
else
begin
	-- network not present, add it.
	select @nNetworkKey = max(NetworkInfoKey) from NetworkInfo
	set @nNetworkKey = @nNetworkKey + 1
	insert NetworkInfo (NetworkInfoKey,
						PlantServerKey,
						NetworkId,
						NetworkName,
						NetworkKindAsString)
				values (@nNetworkKey,
						@nPlantServerKey,
						@sNetworkId,
						@sNetworkName,
						@sNetworkKindAsString)
	if (@@error <> 0)
	begin
		return -3	-- unable to add.
	end
--print 'network info added.'
end

return @nReturn

GO

