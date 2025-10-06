-----------------------------------------------------------------------
-- AmsSp_DevBlk_PutSisStatus_1
--
-- Set the SIS for the device-block.
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
-- Joe Fisher - 08/23/2004
--

CREATE PROCEDURE AmsSp_DevBlk_PutSisStatus_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0
declare @nSisStatus int
set @nSisStatus = cast(@sValue as int)

set nocount on

UPDATE DeviceLocation with (rowlock) set SisStatus = @nSisStatus where BlockKey = @nDevLevelBlockKey
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

