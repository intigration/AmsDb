-----------------------------------------------------------------------
-- AmsSp_GetDevTagAsgms_01
--
-- Get expanded version of BlockAsgms.
-- Recordset is ordered by AmsTag, TimeIn, TimeOut in ascending order.
--
-- Note: times are vtDates in GMT.
--
-- Inputs -
--	none.
--
-- Outputs the following recordset -
--	AmsTag
--	TimeIn
--	TimeOut
--	Manufacturer
--	Protocol
--	MfrId
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber
--	ProtocolRevision
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 06/28/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
Create Procedure AmsSp_GetDevTagAsgms_01
AS

declare @iReturnVal int
set @iReturnVal = 0

    SELECT
	AmsTag, 
	TimeIn, 
	TimeOut,
	Manufacturer, 
   	Protocol, 
	MfrId, 
	DeviceTypeCode, 
	DeviceTypeName, 
	DeviceRevisionCode, 
	DeviceRevisionName, 
	SerialNumber, 
	ProtocolRevision
    FROM AmsVw_DevTagAsgms_1
    ORDER BY AmsTag, TimeIn, TimeOut

declare @Err int, @Rcount int
select @Err = @@ERROR, @Rcount = @@ROWCOUNT

if (@Err <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = @Rcount

return @iReturnVal

GO

