----------------------------------------------------------------------------
-- AmsSp_DeleteInstantiationBlocks_1
--
-- Delete Device's instantiation blocks.
-- Affected tables: InstantiableConfigData, InstantiableBlockAsgms,
--					InstantiableBlockAsgms, EventLog
-- 
-- Input:
--  @@sDevId - Device Identifier
--
--
-- Returns - 0
--
-- Nghy Hong - 08/11/2011
CREATE PROCEDURE AmsSp_DeleteInstantiationBlocks_1
@sDevId nvarchar(255)
AS
--Fetch a list of related events to be deleted later
declare @EventLog Table(EventIdDay int, EventIdFraction int);

insert into @EventLog
select EventLog.EventIdDay, EventLog.EventIdFraction
FROM EventLog INNER JOIN
     InstantiableConfigData ON EventLog.EventIdDay = InstantiableConfigData.EventIdDay AND 
     EventLog.EventIdFraction = InstantiableConfigData.EventIdFraction INNER JOIN
     InstantiableConfigBlocks ON InstantiableConfigData.InstantiableBlockKey = InstantiableConfigBlocks.InstantiableBlockKey INNER JOIN
     Devices ON InstantiableConfigBlocks.DeviceKey = Devices.DeviceKey
WHERE (Devices.Identifier = @sDevId)
GROUP BY EventLog.EventIdDay, EventLog.EventIdFraction

--Delete InstantiableConfigData
DELETE InstantiableConfigData
FROM  InstantiableConfigData INNER JOIN
   InstantiableConfigBlocks ON InstantiableConfigData.InstantiableBlockKey = InstantiableConfigBlocks.InstantiableBlockKey INNER JOIN
   Devices ON InstantiableConfigBlocks.DeviceKey = Devices.DeviceKey
WHERE (Devices.Identifier = @sDevId)

--Delete InstantiableBlockAsgms
DELETE InstantiableBlockAsgms
FROM  InstantiableConfigBlocks INNER JOIN
     Devices ON InstantiableConfigBlocks.DeviceKey = Devices.DeviceKey INNER JOIN
     InstantiableBlockAsgms ON InstantiableConfigBlocks.InstantiableBlockKey = InstantiableBlockAsgms.InstantiableBlockKey
WHERE (Devices.Identifier = @sDevId)

--Delete InstantiableConfigBlocks
DELETE InstantiableConfigBlocks
FROM  InstantiableConfigBlocks INNER JOIN
      Devices ON InstantiableConfigBlocks.DeviceKey = Devices.DeviceKey
WHERE (Devices.Identifier = @sDevId)

--Delete EventLog
DELETE EventLog
FROM EventLog INNER JOIN
@EventLog T on T.EventIdDay = EventLog.EventIdDay and T.EventIdFraction = EventLog.EventIdFraction

return 0;

GO

