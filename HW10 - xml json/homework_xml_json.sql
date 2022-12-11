/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters;

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
------ вариант OPENXML ---------------------------------------------------
DECLARE @x XML, @docHandle int;
SET @x = (SELECT * FROM OPENROWSET (BULK 'C:\1\StockItems.xml', SINGLE_BLOB)  AS d);
EXEC sp_xml_preparedocument @docHandle OUTPUT, @x
---- будеи работать с копией ---------------------------------------------
--------------------------------------------------------------------------
MERGE Warehouse.StockItems AS target 
    USING (SELECT *
            FROM OPENXML(@docHandle, N'/StockItems/Item')
            WITH ( 
                [StockItemName] nvarchar(100) '@Name',
                [SupplierID] int 'SupplierID',
                [UnitPackageID] int 'Package/UnitPackageID',
                [OuterPackageID] int 'Package/OuterPackageID',
                [QuantityPerOuter] int 'Package/QuantityPerOuter',
                [TypicalWeightPerUnit] decimal(18,3) 'Package/TypicalWeightPerUnit',
                [LeadTimeDays] int 'LeadTimeDays',
                [IsChillerStock] bit 'IsChillerStock',
                [TaxRate] decimal(18,3) 'TaxRate',
                [UnitPrice] decimal(18,6) 'UnitPrice')
            ) 
            AS source (
                StockItemName,
                SupplierID,
                UnitPackageID,
                OuterPackageID,
                LeadTimeDays,
                QuantityPerOuter,
                IsChillerStock,
                TaxRate,
                UnitPrice,
                TypicalWeightPerUnit) 
            ON (target.StockItemName = source.StockItemName) 
    WHEN MATCHED 
        THEN UPDATE SET  
                [SupplierID]            = source.[SupplierID]
                ,[UnitPackageID]        = source.[UnitPackageID]
                ,[OuterPackageID]       = source.[OuterPackageID]
                ,[QuantityPerOuter]     = source.[QuantityPerOuter]
                ,[TypicalWeightPerUnit] = source.[TypicalWeightPerUnit]
                ,[LeadTimeDays]         = source.[LeadTimeDays]
                ,[IsChillerStock]       = source.[IsChillerStock]
                ,[TaxRate]              = source.[TaxRate]
                ,[UnitPrice]            = source.[UnitPrice]                    
    WHEN NOT MATCHED 
        THEN INSERT (
		        [StockItemName],
		        [SupplierID],
		        [UnitPackageID],
		        [OuterPackageID],
		        [LeadTimeDays],
		        [QuantityPerOuter],
		        [IsChillerStock],
		        [TaxRate],
		        [UnitPrice],
		        [TypicalWeightPerUnit],
		        [LastEditedBy])
        VALUES (
		        source.[StockItemName],
		        source.[SupplierID],
		        source.[UnitPackageID],
		        source.[OuterPackageID],
		        source.[LeadTimeDays],
		        source.[QuantityPerOuter],
		        source.[IsChillerStock],
		        source.[TaxRate],
		        source.[UnitPrice],
		        source.[TypicalWeightPerUnit],1)
        OUTPUT deleted.*, $action, inserted.*;

--- чистим память --------------------------------------------------------
EXEC sp_xml_removedocument @docHandle
GO
--------------------------------------------------------------------------

--- вариант xquery -------------------------------------------------------
DECLARE @x XML, @docHandle int;
SET @x = (SELECT * FROM OPENROWSET (BULK 'C:\1\StockItems.xml', SINGLE_BLOB)  AS d);
--------------------------------------------------------------------------
MERGE Warehouse.StockItems AS target 
	USING (SELECT  
                t.StockItems.value('(@Name)[1]', 'nvarchar(100)') as [StockItemName],   
                t.StockItems.value('(SupplierID)[1]', 'int') as [SupplierID], 
                t.StockItems.value('(Package/UnitPackageID)[1]', 'int') as [UnitPackageID],
                t.StockItems.value('(Package/OuterPackageID)[1]', 'int') as [OuterPackageID],
                t.StockItems.value('(Package/QuantityPerOuter)[1]', 'int') as [QuantityPerOuter],
                t.StockItems.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)') as [TypicalWeightPerUnit],
                t.StockItems.value('(LeadTimeDays)[1]', 'int') as [LeadTimeDays],
                t.StockItems.value('(IsChillerStock)[1]', 'bit') as [IsChillerStock],
                t.StockItems.value('(TaxRate)[1]', 'decimal(18,3)') as [TaxRate],
                 t.StockItems.value('(UnitPrice)[1]', 'decimal(18,6)') as [UnitPrice]
            FROM @x.nodes('/StockItems/Item') as t(StockItems)
            )
            AS source (
                [StockItemName],
                [SupplierID],
                [UnitPackageID],
                [OuterPackageID],
                [QuantityPerOuter],
                [TypicalWeightPerUnit],
                [LeadTimeDays],
                [IsChillerStock],
                [TaxRate],
                [UnitPrice]) 
			ON (target.StockItemName = source.StockItemName) 
    WHEN MATCHED 
        THEN UPDATE SET  
                [SupplierID]           = source.[SupplierID],
                [UnitPackageID]        = source.[UnitPackageID],
                [OuterPackageID]       = source.[OuterPackageID],
                [QuantityPerOuter]     = source.[QuantityPerOuter],
                [TypicalWeightPerUnit] = source.[TypicalWeightPerUnit],
                [LeadTimeDays]         = source.[LeadTimeDays],
                [IsChillerStock]       = source.[IsChillerStock],
                [TaxRate]              = source.[TaxRate],
                [UnitPrice]            = source.[UnitPrice]                    
        WHEN NOT MATCHED 
        THEN INSERT (
                [StockItemName],
                [SupplierID],
                [UnitPackageID],
                [OuterPackageID],
                [QuantityPerOuter],
                [TypicalWeightPerUnit],
                [LeadTimeDays],				
                [IsChillerStock],
                [TaxRate],
                [UnitPrice],				
                [LastEditedBy])
         VALUES (
                source.[StockItemName],
                source.[SupplierID],
                source.[UnitPackageID],
                source.[OuterPackageID],
                source.[TypicalWeightPerUnit],
                source.[QuantityPerOuter],
                source.[LeadTimeDays],				
                source.[IsChillerStock],
                source.[TaxRate],
                source.[UnitPrice],
                1)
        OUTPUT deleted.*, $action, inserted.*;


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/
--StockItems1.xml
DECLARE @fileName VARCHAR(50)  = 'C:\1\StockItems1.xml'
DECLARE @sqlStr VARCHAR(1000)
DECLARE @sqlCmd VARCHAR(1000)
 
SET @sqlStr  = 'SELECT [StockItemName] AS [@Name], [SupplierID], [UnitPackageID] AS [Package/UnitPackageID], '
SET @sqlStr += '[OuterPackageID] AS [Package/OuterPackageID], [QuantityPerOuter] AS [Package/QuantityPerOuter], '
SET @sqlStr += '[TypicalWeightPerUnit] AS [Package/TypicalWeightPerUnit], [LeadTimeDays], [IsChillerStock], '
SET @sqlStr += '[TaxRate], [UnitPrice] FROM [WideWorldImporters].[Warehouse].[StockItems] ORDER BY [StockItemID] DESC '
SET @sqlStr += 'FOR XML PATH(''Item''), ROOT(''StockItems'')'

SET @sqlCmd = 'bcp "' + @sqlStr + '" queryout ' + @fileName + ' -w -t' + char(13) + ' -T -S ' + @@SERVERNAME
EXEC master..xp_cmdshell @sqlCmd

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT
    [StockItemID], 
    [StockItemName],
    [CountryOfManufacture] = JSON_VALUE(CustomFields, '$.CountryOfManufacture'),
    [FirstTag] = JSON_VALUE(CustomFields, '$.Tags[1]')
FROM
    [Warehouse].[StockItems]

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT
    s.StockItemID,
    s.StockItemName,
    [Tags] = REPLACE(STUFF(JSON_QUERY(s.CustomFields, '$.Tags'), 1, 1,''), ']','')
FROM
    Warehouse.StockItems as s
    CROSS APPLY OPENJSON(s.CustomFields, '$.Tags') AS t
WHERE
    t.value = 'Vintage'
;

