-----------------------------------------------------------------------
-- AmsSp_NetworkInfo_GetNetworksByProperty_1
--
-- Get network information and properties based on a known network property keyword-value pair.
--
--
-- Inputs -
--	@sNetworkKind  -- Network kind (ie. Deltav network, Ovation network).
--	@sNetworkPropertyKey  --  Network property key
--	@sNetworkPropertyValue  --  Network property value
--
-- Outputs recordset as follows --
--	AmsServerName
--	NetworkId
--	NetworkName
--	NetworkKind
--	PropertyKey
--	PropertyValue
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get information.
--
-- Nghy Hong - 04/28/2010
-- John Paul Restubog - 07/26/2010   Added the @sPlantServerName to filter the NetworkInfoKey
--
CREATE PROCEDURE AmsSp_NetworkInfo_GetNetworksByProperty_1
@sNetworkKind nvarchar(255),
@sNetworkPropertyKey nvarchar(255),
@sNetworkPropertyValue nvarchar(255),
@sPlantServerName	nvarchar(4000) = NULL
AS
declare @iReturnVal int
set @iReturnVal = 0

declare @nNetworkInfoKey int
set @nNetworkInfoKey = -999

if (@sPlantServerName IS NOT NULL AND @sPlantServerName <> '')
begin
	SELECT  @nNetworkInfoKey = NetworkInfo.NetworkInfoKey
	FROM   dbo.NetworkInfo INNER JOIN
		   dbo.NetworkInfoProperty ON dbo.NetworkInfo.NetworkInfoKey = dbo.NetworkInfoProperty.NetworkInfoKey INNER JOIN
		   dbo.PlantServer ON dbo.NetworkInfo.PlantServerKey = dbo.PlantServer.PlantServerKey
	WHERE  (dbo.NetworkInfo.NetworkKindAsString = @sNetworkKind)
		AND (dbo.NetworkInfoProperty.NetworkInfoPropertyKey = @sNetworkPropertyKey)
		AND (dbo.NetworkInfoProperty.NetworkInfoPropertyValue = @sNetworkPropertyValue)
		AND (dbo.PlantServer.PlantServerId = @sPlantServerName)
end
else
begin
	SELECT @nNetworkInfoKey = NetworkInfo.NetworkInfoKey
	FROM   dbo.NetworkInfo INNER JOIN
		   dbo.NetworkInfoProperty ON dbo.NetworkInfo.NetworkInfoKey = dbo.NetworkInfoProperty.NetworkInfoKey
	WHERE  (dbo.NetworkInfo.NetworkKindAsString = @sNetworkKind)
		AND (dbo.NetworkInfoProperty.NetworkInfoPropertyKey = @sNetworkPropertyKey)
		AND (dbo.NetworkInfoProperty.NetworkInfoPropertyValue = @sNetworkPropertyValue)	
end

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
	set @iReturnVal = -1	-- did not find network.
end

return @iReturnVal

GO

