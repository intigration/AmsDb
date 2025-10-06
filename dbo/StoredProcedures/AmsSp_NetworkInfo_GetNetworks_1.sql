-----------------------------------------------------------------------
-- AmsSp_NetworkInfo_GetNetworks_1
--
-- Get network information and properties based on Sql Filter.
--
--
-- Inputs -
--	@sSqlFilter  nvarchar(4000) -- if filter is blank then all will be returned.
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
-- Joe Fisher - 02/15/2006
-- John Paul Restubog - 07/26/2010   Added different types of filters
--

CREATE PROCEDURE AmsSp_NetworkInfo_GetNetworks_1
	@sPlantServerName NVARCHAR(255) = NULL,
	@sNetworkId NVARCHAR(255) = NULL,
	@sNetworkName NVARCHAR(1024) = NULL,
	@sNetworkKind NVARCHAR(1024) = NULL
AS
DECLARE @iReturnVal int
DECLARE @sqlQuery NVARCHAR(2000)

SET NOCOUNT ON;

SET @iReturnVal = 0

SET @sPlantServerName = LTRIM(RTRIM(@sPlantServerName))
SET @sNetworkId = LTRIM(RTRIM(@sNetworkId))
SET @sNetworkName = LTRIM(RTRIM(@sNetworkName))
SET @sNetworkKind = LTRIM(RTRIM(@sNetworkKind))

SET @sqlQuery =
'SELECT  PlantServer.PlantServerId AS AmsServerName, 
	NetworkInfo.NetworkId, 
	NetworkInfo.NetworkName, 
	NetworkInfo.NetworkKindAsString AS NetworkKind, 
	NetworkInfoProperty.NetworkInfoPropertyKey AS PropertyKey, 
	NetworkInfoProperty.NetworkInfoPropertyValue AS PropertyValue,
	NetworkInfo.NetworkInfoKey
FROM
	PlantServer INNER JOIN
		NetworkInfo ON PlantServer.PlantServerKey = NetworkInfo.PlantServerKey INNER JOIN
		NetworkInfoProperty ON NetworkInfo.NetworkInfoKey = NetworkInfoProperty.NetworkInfoKey
WHERE 
	PlantServer.PlantServerKey <> - 1 '

IF(@sPlantServerName IS NOT NULL AND @sPlantServerName <> '')
BEGIN
	SET @sqlQuery = @sqlQuery + ' AND PlantServer.PlantServerId = ''' + @sPlantServerName + ''''
END

IF(@sNetworkId IS NOT NULL AND @sNetworkId <> '')
BEGIN
	SET @sqlQuery = @sqlQuery + ' AND NetworkInfo.NetworkId = ''' + @sNetworkId + ''''
END

IF(@sNetworkName IS NOT NULL AND @sNetworkName <> '')
BEGIN
	SET @sqlQuery = @sqlQuery + ' AND NetworkInfo.NetworkName = ''' + @sNetworkName + ''''
END

IF(@sNetworkKind IS NOT NULL AND @sNetworkKind <> '')
BEGIN
	SET @sqlQuery = @sqlQuery + ' AND NetworkInfo.NetworkKindAsString = ''' + @sNetworkKind + ''''
END

EXECUTE (@sqlQuery)

RETURN @iReturnVal

GO

