----------------------------------------------------------------------
-- AmsSp_PsNetworkInfoPropertyDelete_1
--
-- Delete the plant server network component property with that supplied.
--
-- Inputs -
--	@sPlantServerName nvarchar(255)	plant server name.
--	@sNetworkName	  nvarchar(1024)	network's fms.ini 'Name=' value, unique amongst plantServers.
--	@sNetPropKeyword  nvarchar(256) the property keyword
--
-- Outputs -
--	none.
--
-- Returns -
--	0 - successful.
--	-1 - Error, plantServer / network not found.
--  	-99 - Error, general error.
--
-- Joe Fisher 02/13/2006
--
CREATE PROCEDURE AmsSp_PsNetworkInfoPropertyDelete_1
@sPlantServerName nvarchar(255),
@sNetworkName	  nvarchar(1024),
@sNetPropKeyword  nvarchar(256)
AS
declare @nReturn int
declare @nNetworkKey int
declare @nNetworkPropDBKey int
declare @nSPReturn int
declare @nRowCt int
set @nReturn = 0

set nocount on

-- get plantServerKey
exec @nSPReturn = AmsSp_GetPsNetworkKey_1 @sPlantServerName, @sNetworkName, @nNetworkKey output
if (@nSPReturn <> 0)
begin
	return -1	-- problems with getting networkInfo key.
end

delete from NetworkInfoProperty where (NetworkInfoPropertyKey = @sNetPropKeyword) and (NetworkInfoKey = @nNetworkKey)

return @nReturn

GO

