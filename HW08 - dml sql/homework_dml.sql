/*
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

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

--select max([CustomerName]) FROM [WideWorldImporters].[Sales].[Customers]

INSERT INTO [Sales].[Customers]
           ([CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
SELECT TOP (5) --[CustomerID],
      [CustomerName] = 'ZZZ_' + CONVERT(NVARCHAR(20), [CustomerID])
      ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]
  FROM [WideWorldImporters].[Sales].[Customers]
  ORDER BY [CustomerID]
;
--SELECT * FROM [Sales].[Customers] WHERE [CustomerName] LIKE 'ZZZ_%' 

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE TOP (1) FROM [Sales].[Customers]
WHERE [CustomerName] LIKE 'ZZZ_%'

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE TOP (1) C
SET [CustomerName] += '_updated'
FROM [Sales].[Customers] AS C
WHERE [CustomerName] LIKE 'ZZZ_%' 
;

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

-- после проделанных выше упражнений (1 - 3) в результате следующего запроса будет вставлено две записи и обновлено три

MERGE [Sales].[Customers] AS target 
	USING (SELECT TOP (5)
            [CustomerName] = 'ZZZ_' + CONVERT(NVARCHAR(20), [CustomerID])
            ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate] = GETDATE()
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays] = 100
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy] 
		FROM [Sales].[Customers] AS c
		WHERE [CustomerName] NOT LIKE 'ZZZ_%'
		ORDER BY [CustomerID]
		) 
		AS source (
			[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]
		) 
		ON
			(target.[CustomerName] = source.[CustomerName]) 
	WHEN MATCHED 
		THEN UPDATE SET [AccountOpenedDate] = source.[AccountOpenedDate],
						[PaymentDays] = source.[PaymentDays]
	WHEN NOT MATCHED 
		THEN INSERT (
			[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]
			) 
			VALUES (
				source.[CustomerName]
			   ,source.[BillToCustomerID]
			   ,source.[CustomerCategoryID]
			   ,source.[BuyingGroupID]
			   ,source.[PrimaryContactPersonID]
			   ,source.[AlternateContactPersonID]
			   ,source.[DeliveryMethodID]
			   ,source.[DeliveryCityID]
			   ,source.[PostalCityID]
			   ,source.[CreditLimit]
			   ,source.[AccountOpenedDate]
			   ,source.[StandardDiscountPercentage]
			   ,source.[IsStatementSent]
			   ,source.[IsOnCreditHold]
			   ,source.[PaymentDays]
			   ,source.[PhoneNumber]
			   ,source.[FaxNumber]
			   ,source.[DeliveryRun]
			   ,source.[RunPosition]
			   ,source.[WebsiteURL]
			   ,source.[DeliveryAddressLine1]
			   ,source.[DeliveryAddressLine2]
			   ,source.[DeliveryPostalCode]
			   ,source.[DeliveryLocation]
			   ,source.[PostalAddressLine1]
			   ,source.[PostalAddressLine2]
			   ,source.[PostalPostalCode]
			   ,source.[LastEditedBy]
                ) 
    OUTPUT deleted.*, $action, inserted.*;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

-- выгрузка -------------------------------------------------------------
DROP TABLE IF EXISTS [Sales].[Customers_temp]
SELECT TOP 100 [CustomerID], [CustomerName] INTO Sales.Customers_temp
FROM Sales.Customers;

DECLARE @bcp_comm VARCHAR(500) = 'bcp'
SET @bcp_comm += ' "WideWorldImporters.Sales.Customers_temp"'
SET @bcp_comm += ' out "C:\1\Cust.txt" -T -w -t"@@@" -S ' + @@SERVERNAME

exec master..xp_cmdshell @bcp_comm;
-- загрузка -------------------------------------------------------------
DELETE FROM [Sales].[Customers_temp];

BULK INSERT [WideWorldImporters].[Sales].[Customers_temp]
        FROM "C:\1\Cust.txt"
        WITH 
            (
                BATCHSIZE = 1000, 
                DATAFILETYPE = 'widechar',
                FIELDTERMINATOR = '@@@',
                ROWTERMINATOR ='\n',
                KEEPNULLS,
                TABLOCK        
                );

SELECT COUNT(*) FROM [Sales].[Customers_temp]
DROP TABLE IF EXISTS [Sales].[Customers_temp]
