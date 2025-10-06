----------------------------------------------------------------------
-- AmsSp_AssignDevTag_1
--
-- assign the device tag and use the supplied event.
--
-- This will add device tag to the database.
--
-- Also assign the 'Default' test definition name to the final tag name.
--
-- Inputs -
--	@nDeviceLevelBlockKey int
--		This is the Block Key associated to the device level block (ie. BlockIndex = 0).
--	@sAmsTag nvarchar(255)
--		This is the tag name.
--	@nEventIdDay int
--	@nEventIdFraction int
--
-- Outputs -
--	@sFinalAmsTag nvarchar(255)	-- what is finally assigned.
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to assign the tag.
--
-- Joe Fisher 10/1/2003
-- Nghy Hong  10/3/2009 AOEP00033307 Get TestDefinitionName from id instead of hard code the TestDefinitionName
--
CREATE PROCEDURE AmsSp_AssignDevTag_1
@nDeviceLevelBlockKey int,
@sTag nvarchar(255),
@nEventIdDay int,
@nEventIdFraction int,
@sFinalAmsTag nvarchar(255) output
AS
declare @iReturn int
declare @sAmsTagName nvarchar(255)
declare @nTagExists int  --0: exist, -1: not exist
declare @nExtBlockTagKey int
declare @nSPReturn int

-- verify the blockKey is valid
select BlockKey from Blocks where BlockKey = @nDeviceLevelBlockKey
if (@@rowcount = 0)
begin
	return -1
end

-- now go ahead and assign the tag to this device-level block.
set @nTagExists = -1
set @sFinalAmsTag = ''

if len(@sTag) = 0
    begin
	--create a AmsTag name.
	exec AmsSp_CreateAmsTagName_1 @sTag output
    end
else  --to get unassigned tag name
    begin
	exec @nSPReturn = AmsSp_UnassignedTag_Get_1 @sTag, @sAmsTagName output, @nTagExists output 
	if @nSPReturn = -1
	    begin
		print 'exec AmsSp_UnassignedTag_Get_1 error'
		return -1
	    end
	else   
 	    begin
		set @sTag = @sAmsTagName
		print 'unassigned tag name is: ' + @sTag
	   end
    end	
if @nTagExists = -1 --the tag does not exist
    begin
	--add the tag
	exec @nSPReturn = AmsSp_Tag_Add_1 @sTag, @nExtBlockTagKey output
	if @nSPReturn = -1
	    begin
		print 'exec AmsSp_Tag_Add_1 error'
		return -1
	    end
	else
	    begin
	        print 'ExtBlockTagKey is: ' + cast(@nExtBlockTagKey as nvarchar(50))
		set @sFinalAmsTag = @sTag
	    end
    end
else  --the tag does exist
   begin
	--get ExtBlockTagKey for the tag
	select @nExtBlockTagKey = ExtBlockTagKey
	from   ExtBlockTags
	where  ExtBlockTag = @sAmsTagName
	print 'ExtBlockTagKey is: ' + cast(@nExtBlockTagKey as nvarchar(50))
	set @sFinalAmsTag = @sAmsTagName
   end 

--assign the device
insert BlockAsgms(ExtBlockTagKey, 
		  BlockKey,
		  EventIdDayOut,
		  EventIdFractionOut,
		  EventIdDayIn,
		  EventIdFractionIn,
		  Archived)
values(@nExtBlockTagKey, @nDeviceLevelBlockKey, 49710, 0, @nEventIdDay, @nEventIdFraction, 0)
   
if @@ERROR!= 0 
begin
	print 'assign device error'
	return -1
end

--AOEP00033307 Get TestDefinitionName from id instead of hard code the TestDefinitionName
declare @sTestDefinitinoName nvarchar(255)
set @sTestDefinitinoName = ''
select @sTestDefinitinoName = Name from TestDefinition where TestDefinitionId = -1

-- assign the new tag to the 'Default' test definition.
-- use the same eventId that was used in the Tag-device assignment.
exec @nSPReturn = AmsSp_AssignNewTagTestDef_1 @sFinalAmsTag, @sTestDefinitinoName, @nEventIdDay, @nEventIdFraction
if (@nSPReturn <> 0)
begin
	print 'exec AmsSp_AssignNewTagTestDef_1 error- ' + convert(nvarchar(10), @nSPReturn)
	return -1
end

-- done!
return 0

GO

