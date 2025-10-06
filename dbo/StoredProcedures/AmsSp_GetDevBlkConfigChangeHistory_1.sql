
-----------------------------------------------------------------------
-- AmsSp_GetDevBlkConfigChangeHistory_1
--
-- Get device-block configuration change history.
--
-- Inputs -
--	Manufacturer.
--	Protocol.
--	DeviceTypeName.
--	DeviceRevisionName.
--	SerialNumber.
--	Block index (defaults to 0).
--
-- Outputs -
--	Recordset containing list of configuration change dates (in GMT).
--  (see AmsSp_GetBlockKeyConfigChangeHistory_1 for recordset structure.)
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 03/30/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDevBlkConfigChangeHistory_1
@sMfrName as nvarchar(255),
@sProtocolName as nvarchar(255),
@sDeviceTypeName as nvarchar(255),
@sDeviceRevisionName as nvarchar(255),
@sSerialNumber as nvarchar(255),
@nBlockIndex as integer=0
AS
set nocount on

declare @iReturnVal integer
set @iReturnVal = 0
declare @nBlockKey integer

-- get the blockKey.
exec AmsSp_GetDevBlkBlockKey_1 @sMfrName, @sProtocolName, @sDeviceTypeName, @sDeviceRevisionName, @sSerialNumber, @nBlockIndex, @nBlockKey OUTPUT

-- now go ahead and get the configuration change history for this blockKey.
-- this will produce the resultSet we are after.
exec AmsSp_GetBlockKeyConfigChangeHistory_1 @nBlockKey

if (@@ERROR <> 0)
	set @iReturnVal = -1

return @iReturnVal

GO

