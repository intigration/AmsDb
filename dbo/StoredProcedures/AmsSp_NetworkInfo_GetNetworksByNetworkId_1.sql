-----------------------------------------------------------------------
-- AmsSp_NetworkInfo_GetNetworksByNetworkId_1
--
-- 	Get network info 
--
-- Inputs -	@sNetworkId - Network Identifier
--		@sPlantServerName - PlantServer Identifier
--
-- Outputs recordset as follows --
--	AmsServerName
--	NetworkId
--	NetworkName
--	NetworkKind
--	PropertyKey
--	PropertyValue
-- recordset will be order by AmsServerName, NetworkId, NetworkKind, PropertyKey
--	
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get information.
--	-2 - General error
-- Nghy Hong - 8/01/2006
--

CREATE PROCEDURE AmsSp_NetworkInfo_GetNetworksByNetworkId_1
@sNetworkId		nvarchar(4000),
@sPlantServerName	nvarchar(4000)
AS
declare @iReturnVal int
set @iReturnVal = 0

SELECT  PlantServer.PlantServerId AS AmsServerName, 
	NetworkInfo.NetworkId, 
	NetworkInfo.NetworkName, 
	NetworkInfo.NetworkKindAsString AS NetworkKind, 
        NetworkInfoProperty.NetworkInfoPropertyKey AS PropertyKey, 
	NetworkInfoProperty.NetworkInfoPropertyValue AS PropertyValue
FROM    PlantServer INNER JOIN
        NetworkInfo ON PlantServer.PlantServerKey = NetworkInfo.PlantServerKey INNER JOIN
        NetworkInfoProperty ON NetworkInfo.NetworkInfoKey = NetworkInfoProperty.NetworkInfoKey
WHERE  (PlantServer.PlantServerId = @sPlantServerName) AND 
       (NetworkInfo.NetworkId = @sNetworkId)
ORDER BY PlantServer.PlantServerId, 
	NetworkInfo.NetworkId, 
	NetworkInfo.NetworkKindAsString, 
	NetworkInfoProperty.NetworkInfoPropertyKey

-- Row count and error checking
declare @Err int, @RCount int
select @Err = @@ERROR, @RCount = @@ROWCOUNT
if (@Err <> 0)
begin
	set @iReturnVal = -2
end
else
begin
	if (@RCount = 0)
	begin
		set @iReturnVal = -1
	end
end

return @iReturnVal

GO

