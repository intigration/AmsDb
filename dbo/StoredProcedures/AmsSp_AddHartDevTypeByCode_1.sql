
-----------------------------------------------------------------------
-- AmsSp_AddHartDevTypeByCode_1
--
-- Add HART device type info by code.
--
-- Inputs -
--	@nMfrId	       		int
--	@nDeviceTypeCode	int
--	@nDeviceRevisionCode	int
--
-- Outputs -
--	ManufacturerName
--	ProtocolName
--	MfrId
--	DeviceTypeName
--	DeviceTypeCode
--	DeviceRevisionName
--	DeviceRevisionCode
--
-- Returns -
--	0 = successful.
--  -1 - unable to add dev type info.
--	-2 - general error.
--
-- Joe Fisher, 10/15/2003
--
CREATE  PROCEDURE AmsSp_AddHartDevTypeByCode_1
@nMfrId	       			int,
@nDeviceTypeCode		int,
@nDeviceRevisionCode	int,
@sOutManufacturer		nvarchar(255) output,
@sOutProtocolName		nvarchar(255) output,
@nOutMfrId				int output,
@sOutDeviceTypeName		nvarchar(255) output,
@nOutDeviceTypeCode		int output,
@sOutDeviceRevisionName nvarchar(255) output,
@nOutDeviceRevisionCode int output

AS
DECLARE @iReturnVal int
declare @nSpRetVal int
set @iReturnVal = 0

set nocount on

-- we want to make this a atomic operation.
begin transaction

-- get / add this MfrId-Protocol combination.
declare @nMfrProtocolKey int
-- we are always concerned with HART protocol in this process.
declare @sProtocolName nvarchar(255)
set @sProtocolName = 'HART'
-- make up a manufacturer name in case the mfrId-protocol combination is not found.
declare @sManufacturerName nvarchar(255)
-- this makeup is from dbwraps.
set @sManufacturerName = 'Manufacturer ' + cast(@nMfrId as nvarchar(10))
exec @nSpRetVal = AmsSp_MfrProtocols_GetAddId_2 @nMfrId,
												@sProtocolName,
												@sManufacturerName,
												@nMfrProtocolKey output
if (@nSpRetVal <> 0)
begin
	set @iReturnVal = -1
	goto PROBLEM
end

-- get / add the deviceType.
declare @nDeviceTypeKey int
declare @sDeviceTypeCode nvarchar(255)
set @sDeviceTypeCode = cast(@nDeviceTypeCode as nvarchar(255))
declare @sDeviceTypeName nvarchar(255)

-- get DevTypeName if present.
select @sDeviceTypeName = Name from DeviceTypes with (nolock)
where MfrProtocolId = @nMfrProtocolKey and DeviceType = @nDeviceTypeCode

if( @@ROWCOUNT = 0)
begin
	--DevTypeName not found, create a dummy
	set @sDeviceTypeName = cast(@nDeviceTypeCode as nvarchar(255))
	--Is Manufacturer ID only one byte?
	if( @nMfrId <= 0xFF )
	begin		
		--Is Device Type more than one byte?
		if( @nDeviceTypeCode > 0xFF )
		begin
			-- This could be a HART 7 device, which may be backward compatible with a HART 5/6 DD.
			declare @nBackwardCompatableDeviceTypeCode int
			declare @nBackwardCompatableMfgIDCode int
			set @nBackwardCompatableDeviceTypeCode = @nDeviceTypeCode & 0xFF
			set @nBackwardCompatableMfgIDCode = (@nDeviceTypeCode & 0xFF00)/0x100
			--Is the Mfg Id encoded in the first byte of the DeviceType Id?
			if( @nBackwardCompatableMfgIDCode = @nMfrId )
			begin
				-- get DevTypeName From HART5/6 device type, if present.
				select @sDeviceTypeName = Name from DeviceTypes with (nolock)
				where MfrProtocolId = @nMfrProtocolKey and DeviceType = @nBackwardCompatableDeviceTypeCode
				--Paranoia... lets make sure we have something.
				if( @@ROWCOUNT = 0)
				begin
					--DevTypeName not found, create a dummy
					set @sDeviceTypeName = cast(@nDeviceTypeCode as nvarchar(255))
				end
			end
		end
	end
end

declare @sDeviceTypeDesc nvarchar(255)
-- this makeup is from dbwraps.
set @sDeviceTypeDesc = 'Generic Device Type ' + cast(@nDeviceTypeCode as nvarchar(10))
exec @nSpRetVal = AmsSp_DeviceTypes_GetAddId_1 @nMfrProtocolKey,
												@sDeviceTypeCode,
												@sDeviceTypeName,
												@sDeviceTypeDesc,
												@nDeviceTypeKey output
if (@nSpRetVal <> 0)
begin
	set @iReturnVal = -1
	goto PROBLEM
end

-- get / add the deviceRevision.
declare @nDeviceRevKey int
declare @sDeviceRevisionCode nvarchar(255)
set @sDeviceRevisionCode = cast(@nDeviceRevisionCode as nvarchar(255))
declare @sDeviceRevisionName nvarchar(255)
set @sDeviceRevisionName = cast(@nDeviceRevisionCode as nvarchar(255))
declare @sDeviceRevisionDesc nvarchar(255)
set @sDeviceRevisionDesc = cast(@nDeviceRevisionCode as nvarchar(255))
-- need to associate the deviceRevision to some unknown category.
declare @nCategoryKey int
set @nCategoryKey = 0	-- this always unknown.
exec @nSpRetVal = AmsSp_DeviceRevisions_GetAddId_1 @nDeviceTypeKey,
													@sDeviceRevisionCode,
													@nCategoryKey,
													@sDeviceRevisionName,
													@sDeviceRevisionDesc,
													@nDeviceRevKey output
if (@nSpRetVal <> 0)
begin
	set @iReturnVal = -1
	goto PROBLEM
end

-- go ahead and select based on supplied parameters

SELECT     @sOutManufacturer = dbo.Manufacturers.Name,
			@nOutMfrId = dbo.MfrProtocols.MfrId,
			@sOutProtocolName = dbo.DeviceProtocols.Name, 
            @sOutDeviceTypeName = dbo.DeviceTypes.Name,
			@nOutDeviceTypeCode = dbo.DeviceTypes.DeviceType, 
            @sOutDeviceRevisionName = dbo.DeviceRevisions.Name,
			@nOutDeviceRevisionCode = dbo.DeviceRevisions.DeviceRevision
FROM         dbo.Manufacturers with (nolock) INNER JOIN
          dbo.MfrProtocols (nolock) ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
          dbo.DeviceProtocols (nolock) ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
          dbo.DeviceTypes (nolock) ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
          dbo.DeviceRevisions (nolock) ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId
WHERE     (dbo.MfrProtocols.MfrId = @nMfrId) AND 
		(dbo.DeviceProtocols.Name = @sProtocolname) AND
		(dbo.DeviceTypes.DeviceType = @nDeviceTypeCode) AND
		(dbo.DeviceRevisions.DeviceRevision = @nDeviceRevisionCode)

if (@@ROWCOUNT = 0)
begin
	set @iReturnVal = -1
	goto PROBLEM
end

-- SCR AOEP00028584
-- now update alerts in case the device has no DD (Generic HART)
exec @iReturnVal = AmsSp_UpdateDefaultAlerts_1 @nMfrId, @sProtocolname, @nDeviceTypeCode, @nDeviceRevisionCode
if (@iReturnVal <> 0)
begin
	set @iReturnVal = -1
	goto PROBLEM
end

-- successful update.
commit transaction
return 0

PROBLEM:
rollback transaction
return @iReturnVal

GO

