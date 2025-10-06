----------------------------------------------------------------------
-- AmsSp_PsNetworkInfoPropertyList_1
--
-- Get the properties for the given plant server / network.
--
-- Inputs -
--	@sPlantServerName nvarchar(255)	plant server name.
--	@sNetworkName	  nvarchar(1024)	network's fms.ini 'Name=' value, unique amongst plantServers.
--
-- Outputs -
--	none.
--
-- Returns -
--	0 - successful.
--	-1 - Error, plantServer / network not found.
--  	-99 - Error, general error.
--
-- Recordset produced.
--  keyword  value
--
-- Joe Fisher 02/13/2006
--
CREATE PROCEDURE AmsSp_PsNetworkInfoPropertyList_1
@sPlantServerName nvarchar(255),
@sNetworkName	  nvarchar(1024)
AS
declare @nReturn int
declare @nNetworkKey int
declare @nSPReturn int
set @nReturn = 0

set nocount on

-- get plantServerKey
exec @nSPReturn = AmsSp_GetPsNetworkKey_1 @sPlantServerName, @sNetworkName, @nNetworkKey output
if (@nSPReturn <> 0)
begin
	return -1	-- problems with getting networkInfo key.
end

select NetworkInfoPropertyKey as 'keyword',
       NetworkInfoPropertyValue as 'value'
from NetworkInfoProperty
where (NetworkInfoKey = @nNetworkKey)

return @nReturn

GO

