
CREATE PROCEDURE AmsSp_DiagAnalysis_DeviceTypes_1
as
set nocount on

-- first columnName should identify the analysis recordset - value of column should default to blank
SELECT  N'' as DuplicateDeviceTypes,
	m1.Name AS Manufacturer,
	dp1.Name AS Protocol,
	mp1.MfrId as MfrId, 
	dt1.DeviceType AS DevTypeCode,
	dt1.Name AS DevTypeName,
	dr1.DeviceRevision AS DevRevCode, 
	dr1.Name AS DevRevName,
	dt1.AmsDevTypeId as AmsDevTypeId,
	dr1.AmsDevRevId as AmsDevRevId,
	(select count(*) from devices where devices.AmsDevRevId = dr1.AmsDevRevId) as DevCt,
	(select count(*) from NamedConfigs where NamedConfigs.AmsDevRevId = dr1.AmsDevRevId) as NcCt
FROM  dbo.Manufacturers as m1 INNER JOIN
      dbo.MfrProtocols as mp1 ON m1.AmsMfrNameId = mp1.AmsMfrNameId INNER JOIN
      dbo.DeviceProtocols as dp1 ON mp1.ProtocolId = dp1.ProtocolId INNER JOIN
      dbo.DeviceTypes as dt1 ON mp1.MfrProtocolId = dt1.MfrProtocolId INNER JOIN
      dbo.DeviceRevisions as dr1 ON dt1.AmsDevTypeId = dr1.AmsDevTypeId
where   (dp1.Name <> N'Conventional')
	and (1 <
	(select count(*)
	from dbo.Manufacturers as m2 INNER JOIN
                      dbo.MfrProtocols as mp2 ON m2.AmsMfrNameId = mp2.AmsMfrNameId INNER JOIN
                      dbo.DeviceProtocols as dp2 ON mp2.ProtocolId = dp2.ProtocolId INNER JOIN
                      dbo.DeviceTypes as dt2 ON mp2.MfrProtocolId = dt2.MfrProtocolId INNER JOIN
                      dbo.DeviceRevisions as dr2 ON dt2.AmsDevTypeId = dr2.AmsDevTypeId
	where (mp2.MfrId = mp1.MfrId)
		and (dt2.DeviceType = dt1.DeviceType)
		and (dr2.DeviceRevision = dr1.DeviceRevision)
		and (dp1.Name = dp2.Name)
	))
order by m1.Name, dt1.DeviceType, dr1.DeviceRevision, dt1.Name, dr1.Name

-- first columnName should identify the analysis recordset - value of column should default to blank
SELECT  N'' as DuplicateDeviceInstances,
	m1.Name AS Manufacturer,
	dp1.Name AS Protocol,
	mp1.MfrId as MfrId, 
	dt1.DeviceType AS DevTypeCode,
	dt1.Name AS DevTypeName,
	dr1.DeviceRevision AS DevRevCode, 
	dr1.Name AS DevRevName,
	dev1.Identifier as Identifier,
	dev1.ProtocolRevision as ProtocolRevision,
	et1.ExtBlockTag as AmsTag,
	(select count(*) from Blocks as b2 where b2.DeviceKey = dev1.DeviceKey) as BlockCt,
	(select count(*) from BlockData as bd2 where bk1.BlockKey = bd2.BlockKey) as BlockDataCt,
	(select count(*) from BlockAsgms as ba2 where bk1.BlockKey = ba2.BlockKey) as BlockAsgmCt,
	(select count(*) from DeviceMonitorList as ml2 where bk1.BlockKey = ml2.BlockKey) as ScanListCt,
	(select count(*) from Components as hier2 where bk1.BlockKey = hier2.TableKey) as HierarchyCt,
	(select count(*) from EventLog as el2 where bk1.BlockKey = el2.BlockKey) as EventLogCt,
	(select count(*) from AlertLog as al2 inner join eventlog el2a on al2.EventIdDay = el2a.EventIdDay and al2.EventIdFraction = el2a.EventIdFraction where bk1.BlockKey = el2a.BlockKey) as AlertLogCt,
	(select count(*) from SnapOnData as sod2 where bk1.BlockKey = sod2.BlockKey) as SnapOnDataCt,
	(select count(*) from TestResults as tr2 where bk1.BlockKey = tr2.BlockKey) as TestResultsCt,
	dt1.AmsDevTypeId as AmsDevTypeId,
	dr1.AmsDevRevId as AmsDevRevId,
	dev1.DeviceKey as DeviceKey,
	bk1.BlockKey as BlockKey
FROM  dbo.Manufacturers as m1 INNER JOIN
      dbo.MfrProtocols as mp1 ON m1.AmsMfrNameId = mp1.AmsMfrNameId INNER JOIN
      dbo.DeviceProtocols as dp1 ON mp1.ProtocolId = dp1.ProtocolId INNER JOIN
      dbo.DeviceTypes as dt1 ON mp1.MfrProtocolId = dt1.MfrProtocolId INNER JOIN
      dbo.DeviceRevisions as dr1 ON dt1.AmsDevTypeId = dr1.AmsDevTypeId INNER JOIN
      dbo.Devices as dev1 ON dr1.AmsDevRevId = dev1.AmsDevRevId INNER JOIN
      dbo.Blocks as bk1 on dev1.DeviceKey = bk1.DeviceKey INNER JOIN
      dbo.BlockAsgms as ba1 on bk1.BlockKey = ba1.BlockKey INNER JOIN
      dbo.ExtBlockTags as et1 on ba1.ExtBlockTagKey = et1.ExtBlockTagKey
where   (dp1.Name <> N'Conventional') and (ba1.EventIdDayOut = 49710)
	and (1 <
	(select count(*)
	from dbo.Manufacturers as m2 INNER JOIN
                      dbo.MfrProtocols as mp2 ON m2.AmsMfrNameId = mp2.AmsMfrNameId INNER JOIN
                      dbo.DeviceProtocols as dp2 ON mp2.ProtocolId = dp2.ProtocolId INNER JOIN
                      dbo.DeviceTypes as dt2 ON mp2.MfrProtocolId = dt2.MfrProtocolId INNER JOIN
                      dbo.DeviceRevisions as dr2 ON dt2.AmsDevTypeId = dr2.AmsDevTypeId INNER JOIN
		      dbo.Devices as dev2 ON dr2.AmsDevRevId = dev2.AmsDevRevId
	where (mp2.MfrId = mp1.MfrId)
		and (dt2.DeviceType = dt1.DeviceType)
		and (dr2.DeviceRevision = dr1.DeviceRevision)
		and (dev2.Identifier = dev1.Identifier)
		and (dp2.Name = dp1.Name)
	))
order by dev1.Identifier, bk1.BlockKey asc, m1.Name, dt1.DeviceType, dr1.DeviceRevision, dt1.Name

return

GO

