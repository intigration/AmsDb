
-----------------------------------------------------------------------
-- AmsSp_GetDevices_1
--
-- Get list of devices with the following information (see output section.)
-- Note: this filters out the standard default.
--
-- Inputs -
--	none.
--
-- Outputs -
--	Recordset with the following --
--		Manufacturer
--		Protocol
--		Mfrid
--		DeviceTypeCode
--		DeviceTypeName
--		DeviceRevisionCode
--		DeviceRevisionName
--		SerialNumber
--		AmsTag	-- currently assigned (assuming block 0).
--		AmsDeviceId
--		Disposition
--		MajorCategory
--		MinorCategory
--		ProtocolRevision
--		PlantServerId
--
-- Returns -
--	returns number of records in recordset.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 03/19/2000
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDevices_1
AS

declare @iReturnVal int
set @iReturnVal = 0
select * from AmsVw_DeviceTagLocation
WHERE (Manufacturer <> 'Default')
order by Manufacturer,
	Protocol,
	DeviceTypeName,
	DeviceRevisionName,
	SerialNumber

declare @Err int, @Rcount int
select @Err = @@ERROR, @Rcount = @@ROWCOUNT

if (@Err <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = @Rcount

return @iReturnVal

GO

