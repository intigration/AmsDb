-----------------------------------------------------------------------
-- AmsSp_DeviceTypes_GetAddId_1
--
-- Get Device Type Id. if not found, then add it.
--
-- Inputs -
--	@nMfrProtocolId int
--		Manufacture Protocol Id
--	@sDeviceTypeCode nvarchar(255)
--		Device Type code
--	@sName	nvarchar(255)
--		Device Type Name
--	@sDescription	nvarchar(255)
--		Device Type description
--
-- Outputs -
--	nDeviceTypeId
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get mfr id.
--
-- Jane Xiao (6/23/2003)
--

CREATE PROCEDURE AmsSp_DeviceTypes_GetAddId_1
@nMfrProtocolId int,
@sDeviceTypeCode nvarchar(255),
@sName nvarchar(255),
@sDescription nvarchar(255),
@nDeviceTypeId int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get ProtocolID if present.
select @nDeviceTypeId = AmsDevTypeId
from DeviceTypes with (nolock)
where MfrProtocolId = @nMfrProtocolId
and DeviceType = @sDeviceTypeCode

if @@rowcount = 0 
--DevType not found, add it
begin
	-- get the next DevTypeId
	declare @NextDevTypeId int
	select @NextDevTypeId = max(AmsDevTypeId) + 1 from DeviceTypes
	-- add Device Type to db
	insert DeviceTypes with (rowlock) (AmsDevTypeId,MfrProtocolId,DeviceType, Name, Description)
	values (@NextDevTypeId, @nMfrProtocolId, @sDeviceTypeCode, @sName, @sDescription)
	if (@@ERROR <> 0)
	begin
		set @iReturnVal = -1
	end
	else --get new ID
	begin
		set @nDeviceTypeId = @NextDevTypeId
	end
end

return @iReturnVal

GO

