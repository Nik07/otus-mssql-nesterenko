/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

-- напишите здесь свое решение
SELECT 
	YEAR(i.InvoiceDate) AS [Year],
	MONTH(i.InvoiceDate) AS [Month],
	CAST(AVG(il.UnitPrice) AS DEC(18,2)) AS AvgPrice,
	SUM(il.UnitPrice * il.Quantity) AS SumSales
FROM Sales.Invoices AS i
	INNER JOIN Sales.InvoiceLines AS il
		ON il.InvoiceID = i.InvoiceID
GROUP BY 
	YEAR(i.InvoiceDate),
	MONTH(i.InvoiceDate)
ORDER BY
	[Year],
	[Month]
;

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

-- напишите здесь свое решение
SELECT 
	YEAR(i.InvoiceDate) AS [Year],
	MONTH(i.InvoiceDate) AS [Month],
	SUM(il.UnitPrice * il.Quantity) AS SumSales
FROM Sales.Invoices AS i
	INNER JOIN Sales.InvoiceLines AS il
		ON il.InvoiceID = i.InvoiceID
GROUP BY 
	YEAR(i.InvoiceDate),
	MONTH(i.InvoiceDate)
HAVING SUM(il.UnitPrice * il.Quantity) > 4600000
;

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

-- напишите здесь свое решение
SELECT 
	YEAR(i.InvoiceDate) AS [Год продажи],
	MONTH(i.InvoiceDate) AS [Месяц продажи],
	si.StockItemName AS [Наименование товара],
	SUM(il.UnitPrice * il.Quantity) AS [Сумма продаж],
	MIN(i.InvoiceDate) AS [Дата первой продажи],
	SUM(il.Quantity) AS [Количество проданного]
FROM Sales.Invoices AS i
	INNER JOIN Sales.InvoiceLines AS il
		ON il.InvoiceID = i.InvoiceID
	INNER JOIN Warehouse.StockItems AS si 
		ON si.StockItemID = il.StockItemID
GROUP BY 
	YEAR(i.InvoiceDate),
	MONTH(i.InvoiceDate),
	si.StockItemName
HAVING SUM(il.Quantity) < 50
;
-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

-- к запросу 2
-- в формулировке задачи есть некоторая неопределенность, какие годы нужно учитывать, 
-- поэтому ограничим: будем рассматривать только те годы продаж, когда была хотя бы одна продажа.

-- Отобразить все месяцы, где общая сумма продаж превысила 4 600 000, а также все месяцы 
--(по присутствующим годам продаж), в которых не было продаж

SELECT 
	YEAR(i.InvoiceDate) AS [Year],
	MONTH(i.InvoiceDate) AS [Month],
	SUM(il.UnitPrice * il.Quantity) AS SumSales
FROM Sales.Invoices AS i
	INNER JOIN Sales.InvoiceLines AS il
		ON il.InvoiceID = i.InvoiceID
GROUP BY 
	YEAR(i.InvoiceDate),
	MONTH(i.InvoiceDate)
HAVING SUM(il.UnitPrice * il.Quantity) > 4600000
UNION
(SELECT 
	ym.InvoiceYear,
	ym.[Month], 
	0.00 AS SumSales	
FROM 
	(SELECT 
		y.InvoiceYear, 
		Months.[Month]
	 FROM 
		(SELECT DISTINCT YEAR(InvoiceDate) AS InvoiceYear FROM Sales.Invoices) AS y
		CROSS JOIN (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) AS Months([Month])
	 EXCEPT
	 (SELECT DISTINCT 
		YEAR(InvoiceDate), 
		MONTH(InvoiceDate)
	  FROM Sales.Invoices
	 )
    ) as ym
)
;

-- Уточнение: к запросу 3 здесь добавить позиции с месяцами (по присутствующим годам продаж)
-- и существующими товарами, по которым не было продаж в данном периоде

SELECT 
	YEAR(i.InvoiceDate) AS [Год продажи],
	MONTH(i.InvoiceDate) AS [Месяц продажи],
	si.StockItemName AS [Наименование товара],
	SUM(il.UnitPrice * il.Quantity) AS [Сумма продаж],
	MIN(i.InvoiceDate) AS [Дата первой продажи],
	SUM(il.Quantity) AS [Количество проданного]
FROM 
	Sales.Invoices AS i
	INNER JOIN Sales.InvoiceLines AS il
		ON il.InvoiceID = i.InvoiceID
	INNER JOIN Warehouse.StockItems AS si 
		ON si.StockItemID = il.StockItemID
GROUP BY 
	YEAR(i.InvoiceDate),
	MONTH(i.InvoiceDate),
	si.StockItemName
HAVING SUM(il.Quantity) < 50
UNION 
(SELECT 
	ym.InvoiceYear AS [Год продажи],
	ym.[Month] AS [Месяц продажи], 
	ym.StockItemName AS [Наименование товара],
	0.00 AS [Сумма продаж],
	null AS [Дата первой продажи],
	0 As [Количество проданного]
FROM 
	(SELECT 
		y.InvoiceYear, 
		Months.[Month],
		sti.StockItemName
	 FROM 
		(SELECT DISTINCT YEAR(InvoiceDate) AS InvoiceYear FROM Sales.Invoices) AS y
		CROSS JOIN (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) AS Months([Month])
		CROSS JOIN (SELECT DISTINCT StockItemName FROM Warehouse.StockItems) AS sti
	 EXCEPT
	 (SELECT DISTINCT 
		YEAR(Invoices.InvoiceDate), 
		MONTH(Invoices.InvoiceDate), 
		StockItems.StockItemName
	  FROM Sales.Invoices AS Invoices
	  INNER JOIN Sales.InvoiceLines AS InvoiceLines
		ON InvoiceLines.InvoiceID = Invoices.InvoiceID
	  INNER JOIN Warehouse.StockItems AS StockItems 
		ON StockItems.StockItemID = InvoiceLines.StockItemID
	 )
    ) AS ym
)
;
