----------------------------------------------------------------------------
-- AmsSp_InsertTestResult
--
--	Insert TestResult record 
--	Accepts XML form of TestResult record. Format is as follows:
--
--<ROOT>
--<TestResult TestResultId="1" EventIdDay="0123" EventIdFraction="0123" AmsTag="amsTag" TechnicianName="technicianName" WorkOrder="workOrder" ServiceReason="ServiceReason"
--TestEquipmentTag1="testEquipmentTag" TestEquipmentTag2="testEquipmentTag" TestEquipmentTag3="testEquipmentTag" TestEquipmentTag4="testEquipmentTag" 
--TemperatureStd="1" AmbientTemperature="1.1" AmbientTemperatureUnit="1" NotificationLimit="1.1" AdjustmentLimit="1.1" MaxErrorLimit="1.1" ZeroErrorLimit="1.1" 
--LinearityErrorLimit="1.1" HysteresisErrorLimit="1.1" useZeroError="0" useSpanError="0" useLinearityError="0" useHysteresisError="0" ServiceNote="serviceNote" TestResultType="1"
--TestResultData="">
--   <TestResultAFAL TestResultAFALId="1" TestResultAFALType="F" MaxError="5" ZeroError="5" SpanError="5" LinearityError="5" HysteresisError="5" InputLowerRangeValue="1.1" 
--   InputUpperRangeValue="5.5" InputRangeUnits="1" OutputLowerRangeValue="1.1" OutputUpperRangeValue="5.5" OutputRangeUnits="1" Relationship="1" NumberOfTestPoints="3">
--      <TestResultPoint TestResultPointId="1" Error="1.1" Input="1.1" Output="1.1"/>
--      <TestResultPoint TestResultPointId="2" Error="2.2" Input="2.2" Output="2.2"/>
--      <TestResultPoint TestResultPointId="3" Error="3.3" Input="3.3" Output="3.3"/>
--   </TestResultAFAL>
--   <TestResultAFAL TestResultAFALId="2" TestResultAFALType="L" MaxError="5" ZeroError="5" SpanError="5" LinearityError="5" HysteresisError="5" InputLowerRangeValue="1.1" 
--   InputUpperRangeValue="5.5" InputRangeUnits="1" OutputLowerRangeValue="1.1" OutputUpperRangeValue="5.5" OutputRangeUnits="1" Relationship="1" NumberOfTestPoints="3">
--      <TestResultPoint TestResultPointId="4" Error="1.1" Input="1.1" Output="1.1"/>
--      <TestResultPoint TestResultPointId="5" Error="2.2" Input="2.2" Output="2.2"/>
--      <TestResultPoint TestResultPointId="6" Error="3.3" Input="3.3" Output="3.3"/>
--   </TestResultAFAL>   
--</TestResult>
--</ROOT>
-- 
-- Returns -
--	-1 - General error.
--
-- Enrico Resurreccion - 03/20/2012
CREATE PROCEDURE AmsSp_InsertTestResult
@dataAsXML nvarchar(max)
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY


declare @hDoc int
-- prep XML doc
exec sp_xml_preparedocument @hDoc OUTPUT, @dataAsXML

--create table for TestResults
declare @TestResults_Table TABLE(
	TestResultId int,
	EventIdDay int,
	EventIdFraction int,
	AmsTag nvarchar(50),
	BlockIndex int,
	TechnicianName nvarchar(50),
	ServiceReason nvarchar(max),
    WorkOrder nvarchar(max),
    ServiceDescription nvarchar(max),
    TestEquipmentTag1 nvarchar(max),
    TestEquipmentTag2 nvarchar(max),
    TestEquipmentTag3 nvarchar(max),
    TestEquipmentTag4 nvarchar(max),
    TemperatureStd int,
    AmbientTemperature float,
    AmbientTemperatureUnit int,
    NotificationLimit float,
    AdjustmentLimit float,
    MaxErrorLimit float,
    ZeroErrorLimit float,
    SpanErrorLimit float,
    LinearityErrorLimit float,
    HysteresisErrorLimit float,
    UseZeroError bit,
    UseSpanError bit,
    UseLinearityError bit,
    UseHysteresisError bit,
    ServiceNote nvarchar(max),
    TestResultType int,
    TestResultData nvarchar(max))


INSERT INTO @TestResults_Table
SELECT
	TestResultID,
	EventIdDay,
	EventIdFraction,
	AmsTag,
	BlockIndex,
	TechnicianName,
	ServiceReason,
    WorkOrder,
    ServiceDescription,
    TestEquipmentTag1,
    TestEquipmentTag2,
    TestEquipmentTag3,
    TestEquipmentTag4,
    TemperatureStd,
    AmbientTemperature,
    AmbientTemperatureUnit,
    NotificationLimit,
    AdjustmentLimit,
    MaxErrorLimit,
    ZeroErrorLimit,
    SpanErrorLimit,
    LinearityErrorLimit,
    HysteresisErrorLimit,
    UseZeroError,
    UseSpanError,
    UseLinearityError,
    UseHysteresisError,
    ServiceNote,
    TestResultType,
    TestResultData
FROM OPENXML(@hDoc, '/ROOT/TestResult')
WITH 
	(
	TestResultId int,	
	EventIdDay int,
	EventIdFraction int,
	AmsTag nvarchar(50),
	BlockIndex int,
	TechnicianName nvarchar(50),
	ServiceReason nvarchar(max),
    WorkOrder nvarchar(max),
    ServiceDescription nvarchar(max),
    TestEquipmentTag1 nvarchar(max),
    TestEquipmentTag2 nvarchar(max),
    TestEquipmentTag3 nvarchar(max),
    TestEquipmentTag4 nvarchar(max),
    TemperatureStd int,
    AmbientTemperature float,
    AmbientTemperatureUnit int,
    NotificationLimit float,
    AdjustmentLimit float,
    MaxErrorLimit float,
    ZeroErrorLimit float,
    SpanErrorLimit float,
    LinearityErrorLimit float,
    HysteresisErrorLimit float,
    UseZeroError bit,
    UseSpanError bit,
    UseLinearityError bit,
    UseHysteresisError bit,
    ServiceNote nvarchar(max),
    TestResultType int,
    TestResultData nvarchar(max)
	)

--create table for TestResultAFAL
declare @TestResultAFAL_Table TABLE(
	TestResultAFALId int,
	TestResultId int,	
	TestResultAFALType nvarchar(50),	
    MaxError float,
    ZeroError float,
    SpanError float,
    LinearityError float,
    HysteresisError float,
    InputLowerRangeValue float,
    InputUpperRangeValue float,
    InputRangeUnits int,
    OutputLowerRangeValue float,
    OutputUpperRangeValue float,
    OutputRangeUnits float,
    Relationship int,
    NumberOfTestPoints int)


INSERT INTO @TestResultAFAL_Table
SELECT * FROM OPENXML(@hDoc, '/ROOT/TestResult/TestResultAFAL')
WITH (	
	TestResultAFALId int,
	TestResultId int '../@TestResultId',
	TestResultAFALType nvarchar(50),	
    MaxError float,
    ZeroError float,
    SpanError float,
    LinearityError float,
    HysteresisError float,
    InputLowerRangeValue float,
    InputUpperRangeValue float,
    InputRangeUnits int,
    OutputLowerRangeValue float,
    OutputUpperRangeValue float,
    OutputRangeUnits float,
    Relationship int,
    NumberOfTestPoints int)


--create table for TestResultPoints
declare @TestResultPoints_Table TABLE(	
	TestResultAFALId int,
	TestResultPointId int,	
    Input float,
    Output float,
    Error float)
    
    
INSERT INTO @TestResultPoints_Table
SELECT * FROM OPENXML(@hDoc, '/ROOT/TestResult/TestResultAFAL/TestResultPoint')
WITH (	
	TestResultAFALId int '../@TestResultAFALId',
	TestResultPointId int,	
    Input float,
    Output float,
    Error float)
    


--Validate test result
DECLARE @AmsTag nvarchar(255)
DECLARE @TestEquipmentTag1 nvarchar(255)
DECLARE @TestEquipmentTag2 nvarchar(255)
DECLARE @TestEquipmentTag3 nvarchar(255)
DECLARE @TestEquipmentTag4 nvarchar(255)
DECLARE @TestEquipmentId1 int
DECLARE @TestEquipmentId2 int
DECLARE @TestEquipmentId3 int
DECLARE @TestEquipmentId4 int
DECLARE @TechnicianName nvarchar(50)
DECLARE @TechnicianId int
DECLARE @BlockIndex int
DECLARE @BlockKey int
DECLARE @ServiceDescription Nvarchar(50)
DECLARE @ServiceId int
DECLARE @TestResultType int


--im using SELECT here because currently, the stored procedure is accepting a single test result
SELECT TOP 1 @AmsTag = AmsTag, 
	@TestEquipmentTag1 = TestEquipmentTag1,
	@TestEquipmentTag2 = TestEquipmentTag2,
	@TestEquipmentTag3 = TestEquipmentTag3,
	@TestEquipmentTag4 = TestEquipmentTag4,
	@TechnicianName = TechnicianName,
	@ServiceDescription = ServiceReason,
	@TestResultType = TestResultType,
	@BlockIndex = BlockIndex
FROM @TestResults_Table


--since we dont have BlockKey, check if AmsTag exists in database
IF NOT EXISTS(SELECT AmsTag FROM  AmsVw_BlockTags WHERE AmsTag = @AmsTag)
	--AmsTag does not exists in database, return an error
	return -2;
ELSE
	BEGIN
		SELECT @BlockKey = AmsVw_DeviceLevelBlockKey.BlockKey
		FROM AmsVw_BlockTags INNER JOIN
			AmsVw_DeviceLevelBlockKey ON AmsVw_BlockTags.BlockKey = AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey
		WHERE (AmsVw_BlockTags.AmsTag = @AmsTag) AND (AmsVw_DeviceLevelBlockKey.BlockIndex = @BlockIndex);      
	END
	

--check if any TestEquipment exists in database
IF NOT EXISTS(SELECT AmsTag FROM AmsVw_BlockTags WHERE (AmsTag = @TestEquipmentTag1) OR (AmsTag = @TestEquipmentTag2) OR (AmsTag = @TestEquipmentTag3) OR (AmsTag = @TestEquipmentTag4))
	--TestEquipment does not exist in database, return an error and dont insert test result
	return -3;
ELSE
	BEGIN		
		SELECT @TestEquipmentId1 =  Devices.DeviceKey FROM
					Devices INNER JOIN
					Blocks ON 
					Devices.DeviceKey = Blocks.DeviceKey INNER JOIN
					BlockAsgms ON 
					Blocks.BlockKey = BlockAsgms.BlockKey INNER JOIN
					ExtBlockTags ON 
					BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
					WHERE ExtBlockTags.ExtBlockTag = @TestEquipmentTag1
		
		SELECT @TestEquipmentId2 =  Devices.DeviceKey FROM
					Devices INNER JOIN
					Blocks ON 
					Devices.DeviceKey = Blocks.DeviceKey INNER JOIN
					BlockAsgms ON 
					Blocks.BlockKey = BlockAsgms.BlockKey INNER JOIN
					ExtBlockTags ON 
					BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
					WHERE ExtBlockTags.ExtBlockTag = @TestEquipmentTag2
							
		SELECT @TestEquipmentId3 =  Devices.DeviceKey FROM
					Devices INNER JOIN
					Blocks ON 
					Devices.DeviceKey = Blocks.DeviceKey INNER JOIN
					BlockAsgms ON 
					Blocks.BlockKey = BlockAsgms.BlockKey INNER JOIN
					ExtBlockTags ON 
					BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
					WHERE ExtBlockTags.ExtBlockTag = @TestEquipmentTag3
							
		SELECT @TestEquipmentId4 =  Devices.DeviceKey FROM
					Devices INNER JOIN
					Blocks ON 
					Devices.DeviceKey = Blocks.DeviceKey INNER JOIN
					BlockAsgms ON 
					Blocks.BlockKey = BlockAsgms.BlockKey INNER JOIN
					ExtBlockTags ON 
					BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
					WHERE ExtBlockTags.ExtBlockTag = @TestEquipmentTag4
	END


--NULL values should be assgned -1
IF (@TestEquipmentId1 IS NULL)
	SET @TestEquipmentId1 = -1
IF (@TestEquipmentId2 IS NULL)
	SET @TestEquipmentId2 = -1
IF (@TestEquipmentId3 IS NULL)
	SET @TestEquipmentId3 = -1
IF (@TestEquipmentId4 IS NULL)
	SET @TestEquipmentId4 = -1


IF NOT EXISTS (SELECT UserName FROM Users WHERE UserName = @TechnicianName)
	--create a new user. Just using SELECT statement here to prevent errors
	exec AmsSp_InsertAmsUser @TechnicianName, NULL, NULL, @TechnicianId output
ELSE
	SELECT @TechnicianId = Users.UserKey FROM Users WHERE UserName = @TechnicianName
	
	
SELECT @ServiceId = ServiceId FROM ServiceReasons WHERE ServiceDesc = @ServiceDescription

--set default value for TestResultType
IF ((@TestResultType IS NULL) OR (@TestResultType = 0))
	SET @TestResultType = 99


--*******************************All validations passed. Start INSERT operation here.**********************************************
		BEGIN TRY	
			BEGIN TRANSACTION InsertTestResultData
			

				--these will be the handles for the dummy and new IDs
				DECLARE @DummyTestResultId int
				DECLARE @NewTestResultId int
				DECLARE @DummyTestResultAFALId int
				DECLARE @NewTestResultAFALId int
				DECLARE @DummyTestResultPointId int
				DECLARE @NewTestResultPointId int
				
				--initialize all values to NULL
				SET @DummyTestResultId = NULL
				SET @NewTestResultId = NULL
				SET @DummyTestResultAFALId = NULL
				SET @NewTestResultAFALId = NULL
				SET @DummyTestResultPointId = NULL				
				SET @NewTestResultPointId = NULL
				
				--loop through test result
				SELECT @DummyTestResultId = TestResultId FROM @TestResults_Table
				WHILE @DummyTestResultId IS NOT NULL
				BEGIN
					SELECT @NewTestResultId =  MAX(TestResultId) + 1 From TestResults
					IF (@NewTestResultId IS NULL)
						SET @NewTestResultId = 1
					
				
					--insert TestResult using @NewTestResultId
					INSERT INTO TestResults 
					(TestResultId,
					EventIdDay,
					EventIdFraction,
					BlockKey,
					TechnicianId,
					WorkOrder,
					ServiceId,
					TestEquipmentId1,
					TestEquipmentId2,
					TestEquipmentId3,
					TestEquipmentId4,
					TemperatureStd,
					AmbientTemperature,
					AmbientTemperatureUnit,
					NotificationLimit,
					AdjustmentLimit,
					MaxErrorLimit,
					ZeroErrorLimit,
					SpanErrorLimit,
					LinearityErrorLimit,
					HysteresisErrorLimit,
					UseZeroError,
					UseSpanError,
					UseLinearityError,
					UseHysteresisError,
					ServiceNote,
					Type,
					TestResultData)
					SELECT
						@NewTestResultId,
						EventIdDay,
						EventIdFraction,
						@BlockKey,
						@TechnicianId,
						WorkOrder,
						@ServiceId,
						@TestEquipmentId1,
						@TestEquipmentId2,
						@TestEquipmentId3,
						@TestEquipmentId4,
						TemperatureStd,
						AmbientTemperature,
						AmbientTemperatureUnit,
						NotificationLimit,
						AdjustmentLimit,
						MaxErrorLimit,
						ZeroErrorLimit,
						SpanErrorLimit,
						LinearityErrorLimit,
						HysteresisErrorLimit,
						UseZeroError,
						UseSpanError,
						UseLinearityError,
						UseHysteresisError,
						ServiceNote,
						@TestResultType,
						TestResultData
					FROM @TestResults_Table
					
					
					--loop through AFAL 
					SELECT @DummyTestResultAFALId = MIN(TestResultAFALId) FROM @TestResultAFAL_Table WHERE (TestResultId = @DummyTestResultId)			
					WHILE @DummyTestResultAFALId IS NOT NULL
					BEGIN
						SELECT @NewTestResultAFALId =  MAX(TestResultAFALId) + 1 From TestResultAFAL
						IF (@NewTestResultAFALId IS NULL)
							SET @NewTestResultAFALId = 1
					
						INSERT INTO TestResultAFAL
							(TestResultAFALId,
							TestResultId,
							TestResultAFALType,
							MaxError,
							ZeroError,
							LinearityError,
							HysteresisError,
							InputLowerRangeValue,
							InputRangeUnits,
							InputUpperRangeValue,
							OutputLowerRangeValue,
							OutputRangeUnits,
							OutputUpperRangeValue,
							Relationship,
							NumberOfTestPoints)
						SELECT
							@NewTestResultAFALId,
							@NewTestResultId,
							TestResultAFALType,
							MaxError,
							ZeroError,
							LinearityError,
							HysteresisError,
							InputLowerRangeValue,
							InputRangeUnits,
							InputUpperRangeValue,
							OutputLowerRangeValue,
							OutputRangeUnits,
							OutputUpperRangeValue,
							Relationship,
							NumberOfTestPoints
						FROM
							@TestResultAFAL_Table
						WHERE
							TestResultAFALId = @DummyTestResultAFALId
						
						
						--loop through test result point				
						SELECT @DummyTestResultPointId = MIN(TestResultPointId) FROM @TestResultPoints_Table WHERE (TestResultAFALId = @DummyTestResultAFALId)				
						WHILE @DummyTestResultPointId IS NOT NULL
						BEGIN
							SELECT @NewTestResultPointId =  MAX(TestResultPointId) + 1 From TestResultPoints	
							IF (@NewTestResultPointId IS NULL)
								SET @NewTestResultPointId = 1	
							
							INSERT INTO TestResultPoints
								(TestResultAFALId,
								TestResultPointId,
								Input,
								Output,
								Error)
							SELECT
								@NewTestResultAFALId,
								@NewTestResultPointId,
								Input,
								Output,
								Error
							FROM
								@TestResultPoints_Table
							WHERE
								(TestResultPointId = @DummyTestResultPointId)  AND (TestResultAFALId = @DummyTestResultAFALId)
						
							SELECT @DummyTestResultPointId = MIN(TestResultPointId) FROM @TestResultPoints_Table WHERE  (TestResultAFALId = @DummyTestResultAFALId) AND (TestResultPointId > @DummyTestResultPointId)
						END				
						
						SELECT @DummyTestResultAFALId = MIN(TestResultAFALId) 
						FROM @TestResultAFAL_Table 
						WHERE (TestResultId = @DummyTestResultId) AND  (TestResultAFALId > @DummyTestResultAFALId)
					END
					
					
					SELECT @DummyTestResultId = MIN(TestResultId) FROM @TestResults_Table WHERE TestResultId > @DummyTestResultId
				END
						
				
			COMMIT TRANSACTION InsertTestResultData
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION InsertTestResultData
			set @nReturn = -1;  --General error
		END CATCH

-- unload XML doc
exec sp_xml_removedocument @hDoc


END TRY
BEGIN CATCH
      set @nReturn = -1;  --General error
END CATCH

return @nReturn;

GO

