----------------------------------------------------------------------
-- AmsSp_AssignNewTagTestDef_1
--
-- Assign the AmsTag to the test definition.
--
--	NOTE: this does not take into account any current AmsTag / Test Definition
--		assignment at this time.  Should come up with a 'reassign' type
--		procedure.
--
-- Inputs -
--	@sAmsTag nvarchar(255)
--		This is the tag name.
--  @sTestDefinitionName nvarchar(255)
--		This is the test definition name.
--  @nEventIdDay, @nEventIdFraction int
--		This is the event that will be used in the assignment.
--		Note: this event must be present in the EventLog.
--
-- Outputs -
--	none.
--
-- Returns -
--	0 - successful.
--	-1 - Error, tag not present.
--	-2 - Error, test definition not present.
--  -3 - Error, unable to insert the testDefAsgm record.
--  -4 - Error, unable to update the extBlockTag record.
--
-- Joe Fisher 9/24/2003
--
CREATE PROCEDURE AmsSp_AssignNewTagTestDef_1
@sAmsTag nvarchar(255),
@sTestDefinitionName nvarchar(255),
@nEventIdDay int,
@nEventIdFraction int
AS
declare @nTagDbKey int
declare @nTestDefinitionDbKey int
declare @nSPReturn int

-- get the AmsTag's db key.
exec @nSPReturn = AmsSp_AmsTag_GetDbKey_1 @sAmsTag, @nTagDbKey output
if (@nSPReturn <> 0)
begin
	print 'Error-- AmsTag ' + @sAmsTag + ' not found!!!'
	return -1	-- AmsTag not found
end

-- get the test definition name db key.
exec @nSPReturn = AmsSp_TestDefinition_GetDbKey_1 @sTestDefinitionName, @nTestDefinitionDbKey output
if (@nSPReturn <> 0)
begin
	print 'Error-- Test definition ' + @sTestDefinitionName + ' not found!!!'
	return -2	-- Test definition name not found
end


-- check to see if this extBlockTag is currently assigned to a testDefinition.
declare @nRecCt int
select @nRecCt = count(*) from TestDefAsgms
where (ExtBlockTagKey = @nTagDbKey) and
		(EventIdDayOut = 49710) and
		(EventIdFractionOut = 0)
if (@nRecCt = 0)
begin
	-- now go ahead and assign the tag to this test definition.
	begin transaction

	-- assign the test definition to this tag.
	-- Note: we are always going to assign as the current (ie. EventIdDayOut = 49710)
	insert TestDefAsgms(ExtBlockTagKey, 
			  TestDefinitionId,
			  EventIdDayOut,
			  EventIdFractionOut,
			  EventIdDayIn,
			  EventIdFractionIn)
	values(@nTagDbKey, @nTestDefinitionDbKey, 49710, 0, @nEventIdDay, @nEventIdFraction)
	   
	if (@@ERROR != 0 )
	begin
		print 'Error-- assign test definition error- ' + cast(@@ERROR as nvarchar(255))
		print '@nTagDbKey= ' + cast(@nTagDbKey as nvarchar(255))
		print '@nTestDefinitionDbKey= ' + cast(@nTestDefinitionDbKey as nvarchar(255))
		rollback transaction
		return -3
	end

	-- update the AmsTag's testDefinitionId column in the ExtBlockTags table
	update ExtBlockTags set TestDefinitionId = @nTestDefinitionDbKey where ExtBlockTagKey = @nTagDbKey
	
	if (@@ERROR != 0 )
	begin
		print 'Error-- unable to update the ExtBlockTags.TestDefinitionId column'
		rollback transaction
		return -4
	end

	-- success!!
	commit transaction
end

-- success !!
return 0

GO

