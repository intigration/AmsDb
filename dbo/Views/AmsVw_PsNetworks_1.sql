
-------------------------------------------------------------------------------
-- AmsVw_PsNetworks_1
--
-- Get plant servers and associated networks.
--
-- Inputs --
--	none.
--
-- Outputs --
--	PlantServerName
--	PlantServerKey
--	AlertMonitorEnabled
--	NetworkInfoKey
--	NetworkId
--	NetworkName
--	NetworkKindAsString
--
-- Author --
--	Joe Fisher
--	10/1/2003
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE  VIEW dbo.AmsVw_PsNetworks_1
AS
SELECT     	dbo.PlantServer.PlantServerId as PlantServerName,
			dbo.PlantServer.PlantServerKey,
			dbo.PlantServer.AlertMonitorEnabled, 
            dbo.NetworkInfo.NetworkInfoKey,
			dbo.NetworkInfo.NetworkId as NetworkId,
			dbo.NetworkInfo.NetworkName as NetworkName,
			dbo.NetworkInfo.NetworkKindAsString as NetworkKindAsString
FROM         dbo.PlantServer LEFT OUTER JOIN
                      dbo.NetworkInfo ON dbo.PlantServer.PlantServerKey = dbo.NetworkInfo.PlantServerKey
WHERE     (dbo.PlantServer.PlantServerKey <> N'-1')

GO

