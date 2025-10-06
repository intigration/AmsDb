
-------------------------------------------------------------------------------
-- AmsVw_TagBlockAsgms_1
--
-- Get BlockAsgms table information for HART and FF except we are using EventTime instead of
-- EventIdDay's and fraction's.
-- This Vw is a updated version of AmsVw_TagBlockAsgms
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
--	Ying Xu
--	09/22/03
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE  VIEW dbo.AmsVw_TagBlockAsgms_1
AS
SELECT     dbo.ExtBlockTags.ExtBlockTag AS AmsTag, Blocks1.BlockKey, dbo.EventLog.EventTime AS EventTimeOut, EventLog1.EventTime AS EventTimeIn, 
                      Blocks1.BlockType, Blocks1.BlockIndex
FROM         dbo.ExtBlockTags INNER JOIN
                      dbo.BlockAsgms ON dbo.ExtBlockTags.ExtBlockTagKey = dbo.BlockAsgms.ExtBlockTagKey INNER JOIN
                      dbo.EventLog ON dbo.BlockAsgms.EventIdDayOut = dbo.EventLog.EventIdDay AND 
                      dbo.BlockAsgms.EventIdFractionOut = dbo.EventLog.EventIdFraction INNER JOIN
                      dbo.EventLog EventLog1 ON dbo.BlockAsgms.EventIdDayIn = EventLog1.EventIdDay AND 
                      dbo.BlockAsgms.EventIdFractionIn = EventLog1.EventIdFraction INNER JOIN
                      dbo.Blocks ON dbo.BlockAsgms.BlockKey = dbo.Blocks.BlockKey INNER JOIN
                      dbo.Blocks Blocks1 ON dbo.Blocks.DeviceKey = Blocks1.DeviceKey

GO

