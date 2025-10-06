
----------------------------------------------------------------------
-- AmsSp_AlterDbUserPassword
--
-- Update the database user's password
--
-- Inputs -
--	@login			nvarchar(255)	
--  @oldpassword	nvarchar(255)	
--  @password		nvarchar(255)	
--
-- Outputs -
--	none.
--
-- Austin Schuch (1/13/2011)
--
CREATE PROCEDURE AmsSp_AlterDbUserPassword
@login nvarchar(255),
@oldpassword nvarchar(255),
@password nvarchar(255)
AS
BEGIN
      declare @sql nvarchar(255);
      set @sql = 'ALTER LOGIN ' + QUOTENAME(@login) + ' WITH PASSWORD = ' + '''' + @password + '''' + ' OLD_PASSWORD = ' + '''' + @oldpassword + '''';
      exec(@sql);
END

GO

