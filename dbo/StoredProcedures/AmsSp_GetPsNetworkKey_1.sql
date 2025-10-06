-----------------------------------------------------------------------
-- AmsSp_GetPsNetworkKey_1
--
-- Get the database key of the network.
--
-- Inputs -
--	@sPsName	nvarchar(256)	the PlantServer name.
--	@sNetworkName	nvarchar(1024)	the PlantServer name.
--
-- Outputs -
--	@nNetworkInfoKey int	the network database key.
--
-- Returns -
--	0 - success else non-zero.
--
-- Joe Fisher, 02/13/2006
--
CREATE procedure AmsSp_GetPsNetworkKey_1
@sPsName as nvarchar(256),
@sNetworkName	nvarchar(1024),
@nNetworkInfoKey as integer output
as

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

set @nNetworkInfoKey = -1

select @nNetworkInfoKey = NetworkInfoKey from AmsVw_PsNetworks_1
	where (PlantServerName = @sPsName)
	      and (NetworkName = @sNetworkName)

if (@@ROWCOUNT = 0) or (@@ERROR <> 0)
begin
	set @iReturnVal = 1
end

return @iReturnVal

GO

