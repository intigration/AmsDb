
-----------------------------------------------------------------------
-- AmsSp_GetBlockKey_ByUniqueDeviceId_1
--
-- Gets the Device Block Key for the device that can be uniquely identified by its identifier.
-- if not found then returns -999.
--
-- The strDeviceId is unique only in the FF and PROFIBUS device domain.
-- Consequently, this SP should not be used for HART or conventional device, 
-- because HART or conventional device need to be identified by its identifier and device type.
--
-- Inputs -
--	@strDeviceId nvarchar(255)
--		This is the device ID.
--	@strDevProtocol nvarchar(255)
--		This is the Device Protocol.
--
-- Outputs -
--	@nBlockKey int
--		The BlockKey.
--
-- Optional -
--	@nBlockIndex int
--		This is the BlockIndex.
--
-- Returns -
--		0 - successful.
--		-1 - Error
--      -2 - Found more than one BlockKey
--
-- Jane Xiao, 07/30/2003
-- Nghy Hong, 10/06/2009
--
CREATE PROCEDURE AmsSp_GetBlockKey_ByUniqueDeviceId_1
@strDeviceId nvarchar(255),
@strProtocolName nvarchar(255),
@nBlockKey int OUTPUT,
@nBlockIndex int = 0
AS

declare @iReturnVal int
set @iReturnVal = 0
set @nBlockKey = -999
declare @Err int, @Rowcount int

-- get BlockKey if present.
select @nBlockKey = Blocks.BlockKey
from Blocks, Devices, DeviceRevisions, DeviceTypes, MfrProtocols, DeviceProtocols
where Devices.Identifier =  @strDeviceId
and Blocks.BlockIndex = @nBlockIndex
and Devices.DeviceKey = Blocks.DeviceKey
and Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId
and DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId
and DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId
and MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId
and DeviceProtocols.Name = @strProtocolName

select @Err = @@ERROR, @Rowcount = @@ROWCOUNT

if (@Rowcount = 0)
   begin
	set @nBlockKey = -999
   end

if (@Rowcount >1)
   begin
	set @iReturnVal = -2
   end

if @Err != 0 
    set @iReturnVal = -1

return @iReturnVal

GO

