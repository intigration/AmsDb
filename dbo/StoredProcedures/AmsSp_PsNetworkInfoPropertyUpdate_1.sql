----------------------------------------------------------------------
-- AmsSp_PsNetworkInfoPropertyUpdate_1
--
-- Update the plant server network component property with that supplied.
-- If the network property is not present in the database then it is
-- added.
--
-- Inputs -
--	@sPlantServerName nvarchar(255)	plant server name.
--	@sNetworkName	  nvarchar(1024)	network's fms.ini 'Name=' value, unique amongst plantServers.
--	@sNetPropKeyword  nvarchar(256) the property keyword
--	@sNetPropValue	  nvarchar(256) the property value
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
CREATE PROCEDURE AmsSp_PsNetworkInfoPropertyUpdate_1
@sPlantServerName nvarchar(255),
@sNetworkName	  nvarchar(1024),
@sNetPropKeyword  nvarchar(256),
@sNetPropValue	  nvarchar(256)
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

select @nRowCt = count(*) from NetworkInfoProperty
	where (NetworkInfoPropertyKey = @sNetPropKeyword) and (NetworkInfoKey = @nNetworkKey)
print '@nRowCt=' + cast(@nRowCt as nvarchar(10))
if (@nRowCt = 1)
begin
	-- network present, update it.
	select @nNetworkPropDBKey = NetworkInfoPropKey from NetworkInfoProperty
		where (NetworkInfoPropertyKey = @sNetPropKeyword) and (NetworkInfoKey = @nNetworkKey)

	update NetworkInfoProperty set NetworkInfoPropertyValue = @sNetPropValue
		where (NetworkInfoPropertyKey = @sNetPropKeyword) and (NetworkInfoKey = @nNetworkKey)
	if (@@error <> 0)
	begin
		return -2	-- unable to update.
	end
end
else
begin
	-- network property not present, add it.
	select @nNetworkPropDBKey = max(@nNetworkPropDBKey) from NetworkInfoProperty
	set @nNetworkPropDBKey = @nNetworkPropDBKey + 1
	insert NetworkInfoProperty (NetworkInfoKey,
				    NetworkInfoPropertyKey,
				    NetworkInfoPropertyValue)
			    values (@nNetworkKey,
				    @sNetPropKeyword,
				    @sNetPropValue)
	if (@@error <> 0)
	begin
		return -3	-- unable to add.
	end
end

return @nReturn

GO

