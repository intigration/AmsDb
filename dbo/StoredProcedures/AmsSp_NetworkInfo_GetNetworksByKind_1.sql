-----------------------------------------------------------------------
-- AmsSp_NetworkInfo_GetNetworksByKind_1
--
-- Get network information and properties based on the Network Kind.
--
--
-- Inputs -
--	@sPlantServer  nvarchar(255) -- a specific plantserver, if an empty string is passed - all plantservers
--  @sKind nvarchar(1024) -- the kind of network we are returning data for
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
-- James Kramer 9/22/2008
--

CREATE PROCEDURE AmsSp_NetworkInfo_GetNetworksByKind_1
@sPlantServer	nvarchar(255),
@sKind	nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	IF (@sPlantServer = '')
	BEGIN
		SELECT	dbo.PlantServer.PlantServerId as AmsServerName,
			dbo.NetworkInfo.NetworkId as NetworkId,
			dbo.NetworkInfo.NetworkName as NetworkName,
			dbo.NetworkInfo.NetworkKindAsString as NetworkKind, 
				dbo.NetworkInfoProperty.NetworkInfoPropertyKey as PropertyKey,
			dbo.NetworkInfoProperty.NetworkInfoPropertyValue as PropertyValue
		FROM    dbo.PlantServer INNER JOIN
							  dbo.NetworkInfo ON dbo.PlantServer.PlantServerKey = dbo.NetworkInfo.PlantServerKey INNER JOIN
							  dbo.NetworkInfoProperty ON dbo.NetworkInfo.NetworkInfoKey = dbo.NetworkInfoProperty.NetworkInfoKey
		WHERE     ((dbo.PlantServer.PlantServerKey <> - 1) AND
				   (dbo.NetworkInfo.NetworkKindAsString = @sKind))
		ORDER BY dbo.PlantServer.PlantServerId,
			 dbo.NetworkInfo.NetworkId,
			 dbo.NetworkInfo.NetworkKindAsString,
			 dbo.NetworkInfoProperty.NetworkInfoPropertyKey
	END
	ELSE
	BEGIN
		SELECT	dbo.PlantServer.PlantServerId as AmsServerName,
			dbo.NetworkInfo.NetworkId as NetworkId,
			dbo.NetworkInfo.NetworkName as NetworkName,
			dbo.NetworkInfo.NetworkKindAsString as NetworkKind, 
				dbo.NetworkInfoProperty.NetworkInfoPropertyKey as PropertyKey,
			dbo.NetworkInfoProperty.NetworkInfoPropertyValue as PropertyValue
		FROM    dbo.PlantServer INNER JOIN
							  dbo.NetworkInfo ON dbo.PlantServer.PlantServerKey = dbo.NetworkInfo.PlantServerKey INNER JOIN
							  dbo.NetworkInfoProperty ON dbo.NetworkInfo.NetworkInfoKey = dbo.NetworkInfoProperty.NetworkInfoKey
		WHERE     ((dbo.PlantServer.PlantServerKey <> - 1) AND
				   (dbo.PlantServer.PlantServerId = @sPlantServer) AND
				   (dbo.NetworkInfo.NetworkKindAsString = @sKind))
		ORDER BY dbo.PlantServer.PlantServerId,
			 dbo.NetworkInfo.NetworkId,
			 dbo.NetworkInfo.NetworkKindAsString,
			 dbo.NetworkInfoProperty.NetworkInfoPropertyKey
	END
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

