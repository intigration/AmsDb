
-------------------------------------------------------------------------------
-- AmsVw_PsNetworkProperties_1
--
-- Get plant servers and associated networks and their properties.
--
-- Inputs --
--	none.
--
-- Outputs --
--	PlantServerName
--	NetworkId
--	NetworkName
--	NetworkKindAsString
--	NetworkPropertyKeyword
--	NetworkPropertyValue
--
-- Author --
--	Joe Fisher, 02/13/2006
--
CREATE  VIEW dbo.AmsVw_PsNetworkProperties_1
AS
SELECT     dbo.PlantServer.PlantServerId AS PlantServerName, dbo.NetworkInfo.NetworkId, dbo.NetworkInfo.NetworkName, dbo.NetworkInfo.NetworkKindAsString, 
                      dbo.NetworkInfoProperty.NetworkInfoPropertyKey AS NetworkPropertyKeyword, 
                      dbo.NetworkInfoProperty.NetworkInfoPropertyValue AS NetworkPropertyValue
FROM         dbo.NetworkInfoProperty INNER JOIN
                      dbo.NetworkInfo ON dbo.NetworkInfoProperty.NetworkInfoKey = dbo.NetworkInfo.NetworkInfoKey RIGHT OUTER JOIN
                      dbo.PlantServer ON dbo.NetworkInfo.PlantServerKey = dbo.PlantServer.PlantServerKey
WHERE     (dbo.PlantServer.PlantServerKey <> N'-1')

GO

