
-------------------------------------------------------------------------------
-- AmsUdf_GetDevLvlTagAsgm 
--
-- Get the AMS tag for a device level block key which is associated with the given 
-- block key and time values. This function enables us to determine the AMS tag of 
-- FF device Resource and Transducer block events.
--
-- Inputs --
--	nBlockKey - The BlockKey on an event
--	nDay	   - The EventIdDay value of an event
--	nFraction	   - The EventIdFraction value of an event
--
-- Outputs --
--	AmsTag
--
-- Author --
--	Mark Janssen
--	07/16/03
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE FUNCTION AmsUdf_GetDevLvlTagAsgm 
(@nBlockKey int, @nDay int, @nFraction int)  
RETURNS nvarchar(256) 
AS  
BEGIN 
Declare @nDevLvlBlockKey int
Declare @nDeviceKey int
Declare @sAmsTag nvarchar(256)

-- Get the device key for the given block key
Select @nDeviceKey = DeviceKey
From Blocks
Where @nBlockKey = BlockKey

-- Get the device level block key for the given block key
Select @nDevLvlBlockKey = BlockKey
From Blocks
Where (@nDeviceKey = DeviceKey) AND (BlockIndex = 0)

-- Get tag assignment for the device level block key
select @sAmsTag = extblocktags.extblocktag
from extblocktags
inner join blockasgms on (blockasgms.extblocktagkey = extblocktags.extblocktagkey) AND 
( (@nDay < BlockAsgms.EventIdDayOut) OR 
(@nDay = BlockAsgms.EventIdDayOut AND  @nFraction < BlockAsgms.EventIdFractionOut) )
AND 
( (@nDay > BlockAsgms.EventIdDayIn) OR 
( (@nDay = BlockAsgms.EventIdDayIn) AND ( @nFraction >= BlockAsgms.EventIdFractionIn)))
inner join blocks on (blocks.blockkey = blockasgms.blockkey) AND (blockasgms.blockkey = @nDevLvlBlockKey)

Return (Select @sAmsTag As AmsTag)

END

GO

