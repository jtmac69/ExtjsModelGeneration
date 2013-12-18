/*	The Function requires 1st param (string) of the DB object (table or view) name
*	and either values or keyword 'default' for last 3:
*	app Name space (string) -- defaults to 'MyApp'
*	extObject (string) the ExtJS or Touch obect you are extending (defaults to 'Ext.data.Model'
*	the url prefix (string) for the model proxy. pre-pended to the model type, e.g., 
				@restpath = './rest/ml/data/' and @objectName = 'contact'
				proxy url will be './rest/ml/data/contact' (defaults to './rest/pfnd/data/' 
*/
-- Example with all special values for the invoice table
select dbo.generateExtModel('invoice', 'PFNApp', 'MC.data.BaseModel', './rest/ml/data/') as jsstring
go
-- Example with all default values for the invoice table
select dbo.generateExtModel('invoice', default, default, default) as jsstring
go
