-----------------------------------------------------------------------
-- AmsSp_NetworkInfo_GetNetworksByDeltaVHost_1
--
-- Get network information and properties based on Sql Filter.
--
--
-- Inputs -
--	@sDeltaVHostName  nvarchar(4000) -- the DeltaV host name.
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
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get information.
--
-- Joe Fisher - 03/07/2006
--

CREATE PROCEDURE AmsSp_NetworkInfo_GetNetworksByDeltaVHost_1
@sDeltaVHostName	nvarchar(4000)
AS
declare @iReturnVal int
set @iReturnVal = 0

declare @nNetworkInfoKey int
set @nNetworkInfoKey = -999

SELECT @nNetworkInfoKey = NetworkInfo.NetworkInfoKey
FROM   dbo.NetworkInfo INNER JOIN
       dbo.NetworkInfoProperty ON dbo.NetworkInfo.NetworkInfoKey = dbo.NetworkInfoProperty.NetworkInfoKey
WHERE  (dbo.NetworkInfo.NetworkKindAsString = N'DeltaV Network')
	AND (dbo.NetworkInfoProperty.NetworkInfoPropertyKey = N'DeltaVDB Server')
	AND (dbo.NetworkInfoProperty.NetworkInfoPropertyValue = @sDeltaVHostName)


SELECT	dbo.PlantServer.PlantServerId as AmsServerName,
	dbo.NetworkInfo.NetworkId as NetworkId,
	dbo.NetworkInfo.NetworkName as NetworkName,
	dbo.NetworkInfo.NetworkKindAsString as NetworkKind, 
        dbo.NetworkInfoProperty.NetworkInfoPropertyKey as PropertyKey,
	dbo.NetworkInfoProperty.NetworkInfoPropertyValue as PropertyValue
FROM    dbo.PlantServer INNER JOIN
        dbo.NetworkInfo ON dbo.PlantServer.PlantServerKey = dbo.NetworkInfo.PlantServerKey 
	INNER JOIN
        dbo.NetworkInfoProperty ON dbo.NetworkInfo.NetworkInfoKey = dbo.NetworkInfoProperty.NetworkInfoKey
WHERE   (dbo.PlantServer.PlantServerKey <> -1) and (dbo.NetworkInfo.NetworkInfoKey = @nNetworkInfoKey)
ORDER BY dbo.PlantServer.PlantServerId,
	 dbo.NetworkInfo.NetworkId,
	 dbo.NetworkInfo.NetworkKindAsString,
	 dbo.NetworkInfoProperty.NetworkInfoPropertyKey

if (@nNetworkInfoKey = -999)
begin
	return -1	-- did not find network.
end

return @iReturnVal

GO

