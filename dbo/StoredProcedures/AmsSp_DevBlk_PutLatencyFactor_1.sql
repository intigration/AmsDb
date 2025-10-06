-----------------------------------------------------------------------
-- AmsSp_DevBlk_PutLatencyFactor_1
--
-- Set the latencyFactor for the device-block.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--  @sValue			nvarchar		latencyFactor
--
-- Outputs -
--	none
--	
--
-- Returns -
--	0 - successful.
--	-1 - warning- zero records affected- ie. deviceBlockKey not found
--  -2 - error- we had an error while trying to update
--
-- Joe Fisher - 02/12/2007
--

CREATE PROCEDURE AmsSp_DevBlk_PutLatencyFactor_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0
declare @nLatencyFactor smallint
set @nLatencyFactor = cast(@sValue as smallint)

set nocount on

UPDATE DeviceLocation with (rowlock) set LatencyFactor = @nLatencyFactor where BlockKey = @nDevLevelBlockKey
if @@rowcount = 0
begin
	set @iReturnVal = -1
end
if @@error <> 0
begin
	set @iReturnVal = -2
end

return @iReturnVal

GO

