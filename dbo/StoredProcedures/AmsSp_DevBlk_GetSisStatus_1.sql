-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetSisStatus_1
--
-- Get the SisStatus for the device-block.
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
-- Joe Fisher - 08/23/2004
--

CREATE PROCEDURE AmsSp_DevBlk_GetSisStatus_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sValue = ''
declare @nSisStatus int

set nocount on

select top 1 @nSisStatus = SisStatus from DeviceLocation with (nolock) where BlockKey = @nDevLevelBlockKey

if @@rowcount = 1
begin
	set @sValue = cast(@nSisStatus as nvarchar(1024))
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

