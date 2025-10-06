-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetDeviceLevelInfo_1
--
-- Get device-block key along with other stuff.
--
--
-- Inputs -
--	@sManufacturerName	nvarchar(255)
--	@sProtocolName		nvarchar(255)
--	@sDeviceTypeName	nvarchar(255)
--	@sDeviceRevisionName	nvarchar(255)
--	@sIdentifier		nvarchar(255)
--
-- Outputs -
--	@nDeviceLevelBlockKey 	int
--	@sAmsTag		nvarchar(255)
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get DeviceKey.
--
-- Joe Fisher - 8/18/2003
--

CREATE PROCEDURE AmsSp_DevBlk_GetDeviceLevelInfo_1
@sManufacturerName	nvarchar(255),
@sProtocolName		nvarchar(255),
@sDeviceTypeName	nvarchar(255),
@sDeviceRevisionName	nvarchar(255),
@sIdentifier		nvarchar(255),
@nDeviceLevelBlockKey 	int OUTPUT,
@sAmsTag		nvarchar(255) OUTPUT
AS
declare @iReturnVal int
set @iReturnVal = 0
declare @nSpReturn int

set @nDeviceLevelBlockKey = -999
set @sAmsTag = ''

SELECT     @sAmsTag = AmsTag, @nDeviceLevelBlockKey = BlockKey
FROM         dbo.AmsVw_BlockTags with (nolock)
WHERE     (Manufacturer = @sManufacturerName) AND 
		(Protocol = @sProtocolName) AND 
		(DeviceTypeName = @sDeviceTypeName) AND 
		(DeviceRevisionName = @sDeviceRevisionName) AND 
		(SerialNumber = @sIdentifier) AND 
		(BlockIndex = 0)

if (@@ROWCOUNT = 0)
begin
	set @iReturnVal = -1
end

return @iReturnVal

GO

