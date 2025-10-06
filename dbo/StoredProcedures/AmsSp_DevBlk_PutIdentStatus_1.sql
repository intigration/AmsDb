-----------------------------------------------------------------------
-- AmsSp_DevBlk_PutIdentStatus_1
--
-- Set the identStatus for the device-block.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
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
-- Joe Fisher - 10/09/2003
--

CREATE PROCEDURE AmsSp_DevBlk_PutIdentStatus_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0
declare @nIdentStatus int
set @nIdentStatus = cast(@sValue as int)

set nocount on

UPDATE DeviceLocation with (rowlock) set IdentStatus = @nIdentStatus where BlockKey = @nDevLevelBlockKey
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

