## generateExtModel ##

A simple transact SQL (MS SQL) function for generating the Javscript for well-formed Sencha ExtJS and Touch Model Definitions.

**generateExtModel** works for tables and view DB objects.

### Features: ###

- Works for tables and views
- Accurately maps SQL data types to Sencha model field types.
- Allows for specification of the ExtJS or Touch application namespace
- Allows specification of the Ext model type you are extending.
- Allows definition of the proxy url string
- Automatically identifies the primary key as the idProperty

To use, 

1. simply download the SQL script and execute to create the function.
2. Within SQL, exec the function (see examples SQL in repo)

The Function requires the 1st parameter (string) of the DB object (table or view) name and either values or keyword 'default' for last 3:


- app Name space (string) -- defaults to 'MyApp'
- extObject (string) the ExtJS or Touch obect you are extending (defaults to 'Ext.data.Model'
- the urlPrefix (string) for the model proxy. pre-pended to the model type, e.g., 
				@urlPrefix = './rest/ml/data/' and @objectName = 'contact'
				proxy url will be './rest/ml/data/contact' (defaults to './rest/pfnd/data/' 

**Caveat:**  For Non-indexed views and tables without a primary key definition, the first column defined will be used as the idProperty.  You may need to hand-edit the result if you wish to use a different column as the idProperty.

