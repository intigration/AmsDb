
/****** Define our UDFs. ******/
/****** NOTE: We will eventually want to move this section of code to CreateUserDefinedFunctions.sql ******/

-------------------------------------------------------------------------------
-- AmsUdf_GetAlertSource 
--
-- Return the 'alert-source' for the event based on the event category.
-- If the event is a alert category of snap-on then we use the supplied source.
-- Else we supply a 'standard' AMSDMHostProcess value.
--
-- Inputs --
--	@nCategoryType - the category type.
--
-- Outputs --
--	AlertSource as string.
--
-- Author --
--	Joe Fisher
--	02/07/2005
--
CREATE FUNCTION AmsUdf_GetAlertSource 
(@nCategoryType int,
@sEventSource nvarchar(50))  
RETURNS nvarchar(255) 
AS  
BEGIN 
Declare @sAlertSource nvarchar(255)
set @sAlertSource = N''

-- snap-on categories are those that we 'catch' in the 'when-' clauses below.
set @sAlertSource = case @nCategoryType
		when 30 then @sEventSource
		when 31 then @sEventSource
		when 62 then @sEventSource
		when 63 then @sEventSource
		else N'AMSDMHostProcess'
	end

Return (Select @sAlertSource As AlertSource)

END

GO

