/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

DECLARE 
	@Command NVARCHAR(MAX), 
	@Param NVARCHAR(MAX) = NULL

SELECT @Param = ISNULL(@Param + ', ', '') + QUOTENAME(CustomerName)
FROM 
	Sales.Invoices
	JOIN Sales.Customers ON Invoices.CustomerID = Customers.CustomerID
GROUP BY CustomerName
ORDER BY CustomerName

SET @Command = 
	'WITH CTE AS (
		SELECT 
			[PartName] = CustomerName,
			[InvMonth] = DATEADD(MONTH, -1, DATEADD(DAY, 1, EOMONTH(Invoices.InvoiceDate))),
			InvoiceID
		FROM 
			Sales.Invoices
			JOIN Sales.Customers ON Invoices.CustomerID = Customers.CustomerID
		)
	SELECT 
		CONVERT(nvarchar(10), InvMonth, 104) MonthStr, ' + @Param + '
	FROM CTE
	PIVOT (COUNT(InvoiceID) FOR PartName IN (' + @Param + ')
		) AS pvt
	ORDER BY pvt.InvMonth'

EXEC(@Command)
;