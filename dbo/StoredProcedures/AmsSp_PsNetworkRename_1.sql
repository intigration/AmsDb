
----------------------------------------------------------------------
-- AmsSp_PsNetworkRename_1
--
-- Delete the network component associated with this plant server.
--
-- Inputs -
--	@sPlantServerName nvarchar(255)	plant server name.
--  @sNetworkId       nvarchar(255) network id - this is also the section name in the
--                                  ini file and is used to identify the network to 
--                                  rename along with the plant server name.
--  @sNetworkName     nvarchar(255) network name- unique among the ps network group.
--                                  this is the 'Name=' fms.ini value from the network
--                                  component.
--  @sNetworkKindAsString nvarchar(255) string identifying the network type.  Used as a
--                                  sanity check...
--
-- Outputs -
--	none.
--
-- Returns -
--	0 - successful.
--	-1 - Error, Exception during execution
--	-2 - Error, plant server not in database.
--	-3 - Error, network component not in database.
--	-4 - Error, network component in database multiple times.
--
-- Jeff Hagen 9/22/2010
--
CREATE PROCEDURE [dbo].[AmsSp_PsNetworkRename_1]
@sPlantServerName nvarchar(255),
@sNetworkId       nvarchar(255),
@sNetworkName	  nvarchar(255),
@sNetworkKindAsString nvarchar(255)
AS
begin

declare @nReturn int
declare @nPlantServerKey int
declare @nSPReturn int
declare @netCt int
set @nReturn = 0

set nocount on

begin try
	exec @nSPReturn = AmsSp_GetPlantServerKey_1 @sPlantServerName, @nPlantServerKey output
	if (@nSPReturn <> 0)
	begin
		set @nReturn = -2	-- plant server not in database.
	end
	else 
	begin
		select @netCt = count(*) 
		from NetworkInfo 
		where (NetworkId = @sNetworkId) and (PlantServerKey = @nPlantServerKey) and (NetworkKindAsString = @sNetworkKindAsString)

		if (@netCt = 0)
		begin
			-- network not present.
			set @nReturn = -3
		end
		else if (@netCt = 1)
		begin
			update NetworkInfo
			set NetworkName = @sNetworkName
			where NetworkId = @sNetworkId and PlantServerKey = @nPlantServerKey
		end
		else
		begin
			-- too many networks.
			set @nReturn = -4
		end
	end
end try
begin catch
	set @nReturn = -1
end catch

return @nReturn
end

GO

