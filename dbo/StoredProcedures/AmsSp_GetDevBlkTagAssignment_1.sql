
-----------------------------------------------------------------------
-- AmsSp_GetDevBlkTagAssignment_1
--
-- Get device-block tag assignment for a given point in time.
--
-- Inputs -
--	ViewTime - date.
--	Manufacturer.
--	Protocol.
--	DeviceTypeName.
--	DeviceRevisionName.
--	SerialNumber.
--	Block index.
--
-- Outputs -
--	Tag assignment.
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 04/08/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDevBlkTagAssignment_1
@dtViewTime as datetime,
@sMfrName as nvarchar(255),
@sProtocolName as nvarchar(255),
@sDeviceTypeName as nvarchar(255),
@sDeviceRevisionName as nvarchar(255),
@sSerialNumber as nvarchar(255),
@nBlockIndex as integer,
@sAmsTag as nvarchar(255) OUTPUT
AS
set nocount on

declare @iReturnVal integer
set @iReturnVal = 0
declare @nBlockKey integer

-- get the blockKey.
exec AmsSp_GetDevBlkBlockKey_1 @sMfrName, @sProtocolName, @sDeviceTypeName, @sDeviceRevisionName, @sSerialNumber, @nBlockIndex, @nBlockKey OUTPUT

select @dtViewTime

-- setup cursor which will obtain list of assignments for this blockKey.
declare TagAsgmsCursor cursor
forward_only static for
SELECT ExtBlockTags.ExtBlockTag, 
    BlockAsgms.BlockKey, 
    EventLog.EventTime AS TimeOut, 
    EventLog1.EventTime AS TimeIn
FROM ExtBlockTags INNER JOIN
    BlockAsgms ON 
    ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey
     INNER JOIN
    EventLog ON 
    BlockAsgms.EventIdDayOut = EventLog.EventIdDay AND
     BlockAsgms.EventIdFractionOut = EventLog.EventIdFraction
     INNER JOIN
    EventLog EventLog1 ON 
    BlockAsgms.EventIdDayIn = EventLog1.EventIdDay AND 
    BlockAsgms.EventIdFractionIn = EventLog1.EventIdFraction
WHERE (BlockAsgms.BlockKey = @nBlockKey)
-- end of TagAsgmsCursor cursor declaration.

-- go through cursor rows and check where
-- EventTimeIn <= dtViewTime < EventTimeOut
declare @sTag as nvarchar(255)
declare @nBK as integer
declare @dtTimeIn as datetime
declare @dtTimeOut as datetime

set @sAmsTag = ''
open TagAsgmsCursor

fetch next from TagAsgmsCursor into @sTag, @nBK, @dtTimeOut, @dtTimeIn
while (@@fetch_status = 0)
begin
    if (@dtTimeIn <= @dtViewTime) and
       (@dtViewTime < @dtTimeOut)
    begin
	set @sAmsTag = @sTag
	break
    end
    fetch next from TagAsgmsCursor into @sTag, @nBK, @dtTimeOut, @dtTimeIn
end

close TagAsgmsCursor
deallocate TagAsgmsCursor

return @iReturnVal

GO

