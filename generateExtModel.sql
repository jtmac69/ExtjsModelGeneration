/**************************************************************************************

	FILE

		generateExtModel.sql
			
	DESCRIPTION
	
		Function to generate the <modelName>.js fle content
		
		Basically, uses the MS-SQL table or view structure to create the Sencha Extjs or Touch model
		definition using a rest proxy and JSON reader 
		
	PARAMETERS

		name: @objectName varchar
		desc: the SQL table or view name
		vals: existing object in DB
	 default: none; required

		name: @appName varchar
		desc: the namespace of the app
		vals: any
	 default: 'MyApp'

		name: @extObject varchar
		desc: the Ext base model object this definition is extending. i.e., 'Ext.data.Model'
		vals: any
	 default: 'Ext.data.Model'

	 name: @restpath varchar
		desc: the url prefix for the model proxy. pre-pended to the model type, e.g., 
				@restpath = './rest/ml/data/' and @objectName = 'contact'
				proxy url will be './rest/ml/data/contact'
		vals: any
	 default: './rest/pfnd/data/'

	OUTPUT
		name: @modelType varchar
		desc: the final JS string which can be saved into a .js file for use in Sencha Apps
	
	HISTORY
	
		25-Jul-2013		JT McGibbon
			Initial implementation.	
			
*************************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[generateExtModel]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
	drop function [dbo].[generateExtModel]
go

create function dbo.generateExtModel( 
	@objectName	varchar(255), 
	@appName	varchar(255) = 'MyApp', 
	@extObject	varchar(255) = 'Ext.data.Model', 
	@restpath	varchar(255) = './rest/pfnd/data/' 
) returns varchar(max) as 
begin
	--set nocount on

	--	locals
	declare @modelType			varchar(max) -- the final output js string
	declare @columnName			varchar(255) -- current column name
	declare @colType			varchar(255) -- current column datatype
	declare @objHasIdentity		bit			 -- Flag to indicate if DB object has a defined primary key
	declare @isIdentity			bit			 -- Flag to indicate that the current column is the identity (primary key) column
    declare @haveIdField		bit			 -- FLag indicating that we already have the primary key
    declare @haveFirstField		bit			 -- Process control flag to indicate that we are on (or past) the first column
 
	
	set @haveIdField = 0
	set @haveFirstField = 0
--	set @objectName = 'member_broker_searches'
	set @objHasIdentity = (SELECT count(*)			
				FROM sys.objects AS o 
				JOIN sys.columns AS c  ON o.object_id = c.object_id
				WHERE o.name = @objectName
				and is_identity	= 1)

	set @modelType = 'Ext.define("'+@appName+'.model.'+@objectName+'", {'
	set @modelType = @modelType+char(13)+char(10)+'extend: "'+@extObject+'",'+char(13)+char(10)+'alias: "model.'+@objectName+'",'+char(13)+char(10)

	declare model_curs cursor for
			SELECT	LOWER (c.name) AS col_name,
					   CASE 
						WHEN TYPE_NAME(c.user_type_id) = 'int' then 'integer'
						when TYPE_NAME(c.user_type_id) = 'varchar' then 'string'
						when TYPE_NAME(c.user_type_id) = 'text' then 'string'
						when TYPE_NAME(c.user_type_id) = 'bit' then 'boolean'
						when TYPE_NAME(c.user_type_id) = 'decimal' then 'float'
						when TYPE_NAME(c.user_type_id) = 'datetime' then 'date'
						when TYPE_NAME(c.user_type_id) = 'money' then 'number'
						else 'auto'
					   end  AS typeName,
					is_identity				
				FROM sys.objects AS o 
				JOIN sys.columns AS c  ON o.object_id = c.object_id
				WHERE o.name = @objectName
			order by is_identity desc
	
	open model_curs
	fetch next from model_curs into
		@columnName,
		@colType,
		@isIdentity

	while ( @@fetch_status = 0 ) begin
		if (@haveIdField != 1) begin
			if ( @objHasIdentity = 1) begin
				if (@isIdentity = 1) begin
					set @modelType = @modelType+'idProperty: "'+@columnName+'",'+char(13)+char(10)+'fields: ['+char(13)+char(10)
					set @haveIdField = 1
				end
			end
			else begin
				set @modelType = @modelType+'idProperty: "'+@columnName+'",'+char(13)+char(10)+'fields: ['+char(13)+char(10)
				set @haveIdField = 1
			end
		end
		if (@haveFirstField = 1) begin
			set @modelType = @modelType+','+char(13)+char(10)
		end
		
		set @modelType = @modelType+char(9)+'{name: "'+@columnName+'",  type: "'+@colType+'"}'
		set @haveFirstField = 1
  		fetch next from model_curs into
			@columnName,
			@colType,
			@isIdentity
	end

	close model_curs	
	deallocate model_curs
	--./rest/ml/data/ or ./restapi.cfm/data/
    set @modelType = @modelType+'], proxy: { type: "rest", url: "'+@restpath+@objectName+'", reader: {type: "json", root: "data", totalProperty: "totalCount"} }});'

	return @modelType
end