-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetProtocolRevision_1
--
-- Get the Protocol Revision for the devBlkKey.
--
--
-- Inputs -
--	@nDeviceLevelBlockKey	int
--
-- Outputs -
--	@sValue			nvarchar(255)
--		Will be '0' if not found.
--	
--
-- Returns -
--	0 - successful. -1 if not found
--
-- James Kramer - 06/16/2008
--

CREATE PROCEDURE AmsSp_DevBlk_GetProtocolRevision_1
@nDeviceLevelBlockKey	int,
@sValue	nvarchar(255) output
AS
declare @nProtocolRevision int
declare @nReturn int
set @nReturn = 0

BEGIN TRY
	set @nProtocolRevision = -1
	set @sValue = ''

	SELECT @nProtocolRevision = Devices.ProtocolRevision
	FROM Devices INNER JOIN 
		Blocks ON Devices.DeviceKey = Blocks.DeviceKey
	WHERE BlockKey = @nDeviceLevelBlockKey

	if (@nProtocolRevision = -1)
	begin
		set @nReturn = -1
	end
	else
	begin
		set @sValue = cast(@nProtocolRevision as nvarchar(255))
	end
END TRY
BEGIN CATCH
	set @nReturn = -2
END CATCH

	return @nReturn

GO

