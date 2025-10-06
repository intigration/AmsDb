-----------------------------------------------------------------------
-- AmsSp_NetworkInfo_GetAddId_1
--
-- GetAdd the NetworkInfo and return the key.
--
--
-- Inputs -
--	@nPlantServerKey int
--	@sNetworkId		nvarchar(255)
--	@sNetworkName	nvarchar(1024)
--	@sNetworkKindAsString	nvarchar(1024)
--
-- Outputs -
--	@nNetworkInfoKey	int
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to add the information.
--
-- Joe Fisher - 10/1/2003
--

CREATE PROCEDURE AmsSp_NetworkInfo_GetAddId_1
@nPlantServerKey int,
@sNetworkId		nvarchar(255),
@sNetworkName	nvarchar(1024),
@sNetworkKindAsString	nvarchar(1024),
@nNetworkInfoKey	int output
AS
declare @iReturnVal int
set @iReturnVal = 0

SELECT     @nNetworkInfoKey = NetworkInfoKey
from       NetworkInfo with (nolock)
WHERE     (PlantServerKey = @nPlantServerKey) AND (@sNetworkId = NetworkId)

if (@@ROWCOUNT = 0)
begin
	-- entry not found- add it.
	select @nNetworkInfoKey = max(NetworkInfoKey) + 1 from NetworkInfo
	if (@nNetworkInfoKey is null)
	begin
		set @nNetworkInfoKey = 0
	end
	insert NetworkInfo with (rowlock) (NetworkInfoKey,
				PlantServerKey,
				NetworkId,
				NetworkName,
				NetworkKindAsString)
		values	   (@nNetworkInfoKey,
				@nPlantServerKey,
			   @sNetworkId,
			   @sNetworkName,
			   @nNetworkInfoKey)
	if @@error <> 0
	begin
		set @iReturnVal = -1
		return @iReturnVal
	end

end

return @iReturnVal

GO

