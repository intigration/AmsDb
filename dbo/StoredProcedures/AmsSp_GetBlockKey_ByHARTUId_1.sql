
-----------------------------------------------------------------------
-- AmsSp_GetBlockKey_ByHARTUId_1
--
-- Gets the Device Block Key by code; 
-- if not found then returns -999.
-- If found more than one, returns -2
--
--
-- Inputs -
--	@strDeviceId nvarchar(255)
--		This is the device ID.
--	@sMfrId nvarchar(255)
--		This is the mfr id.
--	@sDevType nvarchar(255)
--		This is the device type code.
--	@sDevRev nvarchar(255)
--		This is the device revision.
--
-- Outputs -
--	@nBlockKey int
--		The BlockKey.
-- Optional -
--	@nBlockIndex int
--		This is the BlockIndex.
--
-- Returns -
--	0 - successful.
--	-1 - Error
--      -2 - found more than one BlockKey
--
-- Jane Xiao, 07/30/2003
--
CREATE PROCEDURE AmsSp_GetBlockKey_ByHARTUId_1
@strDeviceId nvarchar(255),
@sMfrId nvarchar(255),
@sDevType nvarchar(255),
@sDeviceRevisionCode nvarchar(255),
@sProtocolRev nvarchar(255),
@sProtocolName nvarchar(255),
@nBlockKey int OUTPUT,
@nBlockIndex int = 0
AS

declare @iReturnVal int
set @iReturnVal = 0
set @nBlockKey = -999
declare @Err int, @Rowcount int

-- get BlockKey if present.
select @nBlockKey = Blocks.BlockKey
from Blocks, Devices
where Devices.Identifier =  @strDeviceId
and Blocks.BlockIndex = @nBlockIndex
and Devices.DeviceKey = Blocks.DeviceKey
and Devices.ProtocolRevision = @sProtocolRev
and Devices.AmsDevRevId in (select DeviceRevisions.AmsDevRevId 
			    from DeviceRevisions, DeviceTypes, MfrProtocols, DeviceProtocols
			    where MfrProtocols.MfrProtocolId = DeviceTypes.MfrProtocolId
			    and MfrProtocols.mfrId = @sMfrId
			    and DeviceTypes.DeviceType = @sDevType
			    and DeviceProtocols.name = @sProtocolName
				and DeviceRevisions.DeviceRevision = @sDeviceRevisionCode
			    and DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId
			    and MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId)

select @Err = @@ERROR, @Rowcount = @@ROWCOUNT

if (@Rowcount = 0)
   begin
	set @nBlockKey = -999
   end


if (@Rowcount > 1)
   begin
	set @iReturnVal = -2
   end

if @Err != 0 
    set @iReturnVal = -1

return @iReturnVal

GO

