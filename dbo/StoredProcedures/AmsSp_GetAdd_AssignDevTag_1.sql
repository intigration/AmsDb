----------------------------------------------------------------------
-- AmsSp_GetAdd_AssignDevTag_1
--
-- Assign device tag.
--
-- This will add device tag to the database.
--
-- Inputs -
--	@nEventIdDay int
--		This is the Event Id.
--	@nEventIdFraction int
--		This is the Event Id.
--	@nBlockKey int
--		This is the Block Key.
--	@sAmsTag nvarchar(255)
--		This is the tag name.
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to assign the tag.
--
-- Jane Xiao, 7/2/2003
--
CREATE PROCEDURE AmsSp_GetAdd_AssignDevTag_1
@nEventIdDay int,
@nEventIdFraction int,
@nBlockKey int,
@sTag nvarchar(255)
AS
declare @iReturn int
declare @sAmsTagName nvarchar(255)
declare @nTagExists int  --0: exist, -1: not exist
declare @nExtBlockTagKey int
declare @nSPReturn int

set @nTagExists = -1

if len(@sTag) = 0
    begin
	--use current datetime as tag name
	set @sTag = convert(nvarchar(50), getdate(), 126)  
	set @nTagExists = -1
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
	    print 'ExtBlockTagKey is: ' + cast(@nExtBlockTagKey as nvarchar(50))
    end
else  --the tag does exist
   begin
	--get ExtBlockTagKey for the tag
	select @nExtBlockTagKey = ExtBlockTagKey
	from   ExtBlockTags with (nolock)
	where  ExtBlockTag = @sAmsTagName
	print 'ExtBlockTagKey is: ' + cast(@nExtBlockTagKey as nvarchar(50))
   end 

--assign the device
insert BlockAsgms with (rowlock) (ExtBlockTagKey, 
		  BlockKey,
		  EventIdDayOut,
		  EventIdFractionOut,
		  EventIdDayIn,
		  EventIdFractionIn,
		  Archived)
values(@nExtBlockTagKey, @nBlockKey, 49710, 0, @nEventIdDay, @nEventIdFraction, 0)
   
 
if @@ERROR!= 0 
    begin
	print 'assign device error'
	return -1
    end
else
    begin
	return 0
    end

GO

