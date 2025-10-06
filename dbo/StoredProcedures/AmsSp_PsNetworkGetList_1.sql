----------------------------------------------------------------------
-- AmsSp_PsNetworkGetList_1
--
-- Get the list of networks associated with the plant server.
--
-- Inputs -
--	@sPlantServerName nvarchar(255)	plant server name.
--
-- Outputs -
--	recordset --
--	@sNetworkId		  nvarchar(255)	network name- unique among the ps network group.
--  @sNetworkName	  nvarchar(1024)	network description.
--	@sNetworkKindAsString	  nvarchar(1024)	network kind (as string.)
--
-- Returns -
--	0 - if successful.
--  -1 - if an error detected.
--
-- Joe Fisher 10/1/2003
--
CREATE PROCEDURE AmsSp_PsNetworkGetList_1
@sPlantServerName nvarchar(255)
AS
declare @nReturn int
set @nReturn = 0

set nocount on

SELECT     dbo.NetworkInfo.NetworkId as NetworkId,
			dbo.NetworkInfo.NetworkName as NetworkName,
			dbo.NetworkInfo.NetworkKindAsString as NetworkKindAsString
FROM         dbo.PlantServer INNER JOIN
               dbo.NetworkInfo ON dbo.PlantServer.PlantServerKey = dbo.NetworkInfo.PlantServerKey
WHERE     (PlantServerId = @sPlantServerName)
ORDER BY NetworkId asc

if (@@error <> 0)
begin
	set @nReturn = -1
end

return @nReturn

GO

