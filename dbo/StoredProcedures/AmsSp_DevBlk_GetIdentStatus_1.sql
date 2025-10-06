-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetIdentStatus_1
--
-- Get the identState for the device-block.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--
-- Outputs -
--	@sValue nvarchar(1024)	string value of state (ie. '0', '1', etc.)
--	
--
-- Returns -
--	0 - successful.
--	-1 - warning- deviceBlockKey not found
--  -2 - error- we had an error while trying to get data.
--
-- Joe Fisher - 10/09/2003
--

CREATE PROCEDURE AmsSp_DevBlk_GetIdentStatus_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sValue = ''
declare @nIdentStatus int

set nocount on

select top 1 @nIdentStatus = IdentStatus from DeviceLocation with (nolock) where BlockKey = @nDevLevelBlockKey

if @@rowcount = 1
begin
	set @sValue = cast(@nIdentStatus as nvarchar(1024))
end
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

