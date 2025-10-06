
-------------------------------------------------------------------------------
-- AmsVw_TagBlockAsgms
--
-- Get BlockAsgms table information except we are using EventTime instead of
--	EventIdDay's and fraction's.
--
-- REMEMBER-- all times are GMT.
--
-- Inputs --
--	none.
--
-- Outputs --
--	AmsTag
--	BlockKey
--	EventTimeOut
--	EventTimeIn
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_TagBlockAsgms
AS
SELECT ExtBlockTags.ExtBlockTag AS AmsTag, 
    BlockAsgms.BlockKey, 
    EventLog.EventTime AS EventTimeOut, 
    EventLog1.EventTime AS EventTimeIn
FROM ExtBlockTags INNER JOIN
    BlockAsgms ON 
    ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey INNER
     JOIN
    EventLog ON 
    BlockAsgms.EventIdDayOut = EventLog.EventIdDay AND 
    BlockAsgms.EventIdFractionOut = EventLog.EventIdFraction INNER
     JOIN
    EventLog EventLog1 ON 
    BlockAsgms.EventIdDayIn = EventLog1.EventIdDay AND 
    BlockAsgms.EventIdFractionIn = EventLog1.EventIdFraction

GO

