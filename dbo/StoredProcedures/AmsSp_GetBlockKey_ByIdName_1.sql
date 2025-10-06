
-----------------------------------------------------------------------
-- AmsSp_GetBlockKey_ByIdName_1
--
-- Gets the Device Block Key by name; 
-- if not found then returns -999.
-- if found more than one, returns -2
--
--
-- Inputs -
--	@strDeviceId nvarchar(255)
--		This is the device ID.
--	@strMfrName nvarchar(255)
--		This is the mfr name.
--	@strDevTypeName nvarchar(255)
--		This is the device type name.
--	@strDevRev nvarchar(255)
--		This is the device revision.
--	@strDevProtocol nvarchar(255)
--		This is the device protocol name.
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
--	0 - successful.
--	-1 - Error
--      -2 - found more than one BlockKey
--
-- Jane Xiao, 07/30/2003
--
CREATE PROCEDURE AmsSp_GetBlockKey_ByIdName_1
@strDeviceId nvarchar(255),
@strMfrName nvarchar(255),
@strDevTypeName nvarchar(255),
@strDevRev nvarchar(255),
@strProtocolName nvarchar(255),
@nBlockKey int OUTPUT,
@nBlockIndex int = 0
AS

declare @iReturnVal int
set @iReturnVal = 0
set @nBlockKey = -999
declare @Err int, @nRow int

-- get BlockKey if present.
select @nBlockKey = Blocks.BlockKey
from Blocks, Devices
where Devices.Identifier =  @strDeviceId
and Blocks.BlockIndex = @nBlockIndex
and Devices.DeviceKey = Blocks.DeviceKey
and Devices.AmsDevRevId in (select DeviceRevisions.AmsDevRevId 
			    from DeviceRevisions, DeviceTypes, MfrProtocols, Manufacturers, DeviceProtocols
			    where MfrProtocols.MfrProtocolId = DeviceTypes.MfrProtocolId
			    and Manufacturers.Name = @strMfrName
			    and DeviceTypes.Name = @strDevTypeName
			    and DeviceRevisions.DeviceRevision = @strDevRev
			    and DeviceProtocols.name = @strProtocolName
			    and DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId
			    and Manufacturers.AmsMfrNameId = MfrProtocols.AmsMfrNameId
			    and MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId)

select @Err = @@ERROR, @nRow = @@ROWCOUNT

if (@nRow = 0)
   begin
	set @nBlockKey = -999
   end

if (@nRow > 1)
   begin
	set @iReturnVal = -2
   end

if @Err != 0 
    set @iReturnVal = -1

return @iReturnVal

GO

