-----------------------------------------------------------------------
-- AmsSp_NetworkInfo_GetDbKey_ByPsNetworkId_1
--
-- Return the database keys for the plantServer and it's network fms.ini section header.
--
--
-- Inputs -
--	@sPlantServerName	nvarchar(255) -- the plantServer name.
--	@sNetworkId		nvarchar(255) -- correspondes to fms.ini section header
--
-- Outputs -
--	@nPlantServerKey	int
--	@nNetworkInfoKey	int
--	
--
-- Returns -
--	0 - successful.
--	-1 - network not found.
--	-2 - general error.
--
-- Joe Fisher - 4/25/2006
--

CREATE PROCEDURE AmsSp_NetworkInfo_GetDbKey_ByPsNetworkId_1
@sPlantServerName	nvarchar(255),
@sNetworkId		nvarchar(255),
@nPlantServerKey	int output,
@nNetworkInfoKey	int output
AS
declare @iReturnVal int
set @iReturnVal = -1

SELECT     @nPlantServerKey = ps.PlantServerKey,
	   @nNetworkInfoKey = ni.NetworkInfoKey
from       NetworkInfo as ni with (nolock) inner join PlantServer as ps with (nolock)
		on ni.PlantServerKey = ps.PlantServerKey
WHERE     (@sPlantServerName = ps.PlantServerId) and (@sNetworkId = ni.NetworkId)

if (@@ROWCOUNT <> 0)
begin
	set @iReturnVal = 0
end
else
begin
	set @nPlantServerKey = -999
	set @nNetworkInfoKey = -999
	set @iReturnVal = -1
end

return @iReturnVal

GO

