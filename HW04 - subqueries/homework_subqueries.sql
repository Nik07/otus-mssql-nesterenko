/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT p.PersonID, p.FullName
FROM [Application].People AS p
WHERE 
	(p.IsSalesperson = 1) 
	AND NOT EXISTS (
		SELECT null 
		FROM Sales.Invoices AS i
		WHERE (i.SalespersonPersonID = p.PersonID)
			AND (i.InvoiceDate = '2015-07-04'))
; 

-- через WITH
WITH sp AS (
	SELECT SalespersonPersonID 
	FROM Sales.Invoices
	WHERE InvoiceDate = '2015-07-04')

SELECT p.PersonID, p.FullName
FROM 
	Application.People AS p
WHERE 
	(p.IsSalesperson = 1) 
	AND (p.PersonID NOT IN (
			SELECT SalespersonPersonID 
			FROM sp)
		)
;

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

DECLARE @MinPrice DECIMAL(18,2) = (SELECT MIN(UnitPrice) FROM Warehouse.StockItems)

SELECT 
	StockItemID, 
	StockItemName, 
	UnitPrice
FROM Warehouse.StockItems
WHERE UnitPrice = @MinPrice
;

-- через WITH
WITH mp (MinPrice) AS (
	SELECT MIN(UnitPrice) FROM Warehouse.StockItems)

SELECT 
	StockItemID, 
	StockItemName, 
	UnitPrice
FROM Warehouse.StockItems
WHERE UnitPrice IN (SELECT MinPrice FROM mp)
;

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

-- TOP (5) или TOP (5) WITH TIES в данном случае одинаковый результат

SELECT c.* 
FROM Sales.Customers AS c
WHERE 
	c.CustomerID IN (
		SELECT TOP (5) CustomerID 
		FROM Sales.CustomerTransactions
		ORDER BY TransactionAmount DESC
		)
;

-- через WITH
WITH ma (CustomerId) AS (
	SELECT TOP(5) CustomerId
	FROM Sales.CustomerTransactions 
	ORDER BY TransactionAmount DESC
)

SELECT c.*
FROM 
	Sales.Customers AS c
WHERE c.CustomerID IN 
	(SELECT CustomerId FROM ma)
;

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

-- некоторое уточнение: 
-- если у нас есть товары с одинаковой ценой, то может оказаться, что в тройку самых дорогих входит более чем три товара
-- можно конечно случайно выбрать из них три (использовать TOP(3)), а можно все взять (использовать TOP(3) WITH) 
-- в последнем случае результат будет детерминированным

SELECT 
	cp.DeliveryCityID,
	c.CityName,
	ISNULL(p.FullName, 'Unknown') PickerName
FROM 
	(SELECT DISTINCT c.DeliveryCityID, o.PickedByPersonID
		FROM Sales.Orders AS o
		JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
		WHERE o.OrderId IN (
			SELECT OrderId 
				FROM (
					SELECT DISTINCT OrderID
						FROM Sales.OrderLines
						WHERE StockItemID IN (
							SELECT StockItemID 
								FROM (
									SELECT TOP (3) WITH TIES StockItemID
										FROM Warehouse.StockItems
										ORDER BY UnitPrice DESC
								) AS Items
						)
				    ) AS OrderIds
			)
	) AS cp	
	INNER JOIN Application.Cities AS c
		ON c.CityId = cp.DeliveryCityID
	LEFT JOIN Application.People p 
		ON p.PersonID = cp.PickedByPersonID
;

-- через WITH
WITH Items (StockItemID) AS (
	SELECT TOP (3) WITH TIES StockItemID
	FROM Warehouse.StockItems
	ORDER BY UnitPrice DESC
), 
OrderIds (OrderId) AS (
	SELECT DISTINCT OrderID
	FROM Sales.OrderLines
	WHERE StockItemID IN (SELECT StockItemID FROM Items)
), 
cp (CityID, PickerId) AS (
	SELECT DISTINCT c.DeliveryCityID, o.PickedByPersonID
	FROM 
		Sales.Orders AS o
		JOIN Sales.Customers c
			ON c.CustomerID = o.CustomerID
	WHERE o.OrderId IN (SELECT OrderId FROM OrderIds)
)

SELECT 
	cp.CityID,
	c.CityName,
	ISNULL(p.FullName, 'Unknown') PickerName
FROM 
	cp
	INNER JOIN Application.Cities AS c
		ON c.CityId = cp.CityID
	LEFT JOIN Application.People p 
		ON p.PersonID = cp.PickerId
;

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос
SET STATISTICS IO, TIME ON

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
;
-- Запрос выбирает счет-фактуры (закупки) с суммой по строкам больше, чем 27000
-- сортирует их по убыванию общей суммы
-- выводит:
-- ид счета-фактуры, 
-- дату счета-фактуры, 
-- имя продавца, 
-- сумма счета-фактуры (по строкам)
-- сумма по "доставленным" заказам :по строкам заказа, соответствующего счету-фактуре  (по выбранному количеству PickedQuantity), 
--      но только, если выборка по заказу завершена

-- Оптимизация
-- перемещаем расчет поля SalesPersonName в JOIN
-- выделяем CTE для формирования информации по выбранным счетам-фактурам с суммами
-- выделяем CTE для формирования информации по "доставленным" заказам

-- сначала я переписал запрос, как бы я его с нуля написал
-- Оптимизация 1 эта оптимизация мне больше нравится
WITH SalesTotals (InvoiceId, TotalSumm) AS (
	SELECT InvoiceId, SUM(Quantity * UnitPrice)
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity * UnitPrice) > 27000
),
PickingCompletedOrders (OrderId, TotalSummForPickedItems) AS (
	SELECT OrderLines.OrderId, SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice)
		FROM Sales.OrderLines
		JOIN Sales.Orders ON Orders.OrderID  = OrderLines.OrderId
			AND Orders.PickingCompletedWhen IS NOT NULL
		GROUP BY OrderLines.OrderId
)

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	PickingCompletedOrders.TotalSummForPickedItems
FROM SalesTotals 
	JOIN Sales.Invoices ON SalesTotals.InvoiceId = Invoices.InvoiceID
	JOIN Application.People ON People.PersonID = Invoices.SalespersonPersonID	
	LEFT JOIN PickingCompletedOrders ON PickingCompletedOrders.OrderId = Invoices.OrderId
ORDER BY 
	SalesTotals.TotalSumm DESC
;

-- оптимизация 2 ( в определенный момент с ней было лучше, но потом оптимизатор по видимомму обучился и он стал хуже предыдущих)
WITH SalesTotals (InvoiceId, TotalSumm) AS (
	SELECT InvoiceId, SUM(Quantity * UnitPrice)
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity * UnitPrice) > 27000
),
PickingCompletedOrders (InvoiceID, TotalSummForPickedItems) AS (
	SELECT Invoices.InvoiceID, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.Invoices
		JOIN Sales.Orders ON Orders.OrderID  = Invoices.OrderId
			AND Orders.PickingCompletedWhen IS NOT NULL
		JOIN Sales.OrderLines ON OrderLines.OrderId = Orders.OrderID
		GROUP BY Invoices.InvoiceID
)

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	PickingCompletedOrders.TotalSummForPickedItems
FROM SalesTotals 
	JOIN Sales.Invoices ON SalesTotals.InvoiceId = Invoices.InvoiceID
	JOIN Application.People ON People.PersonID = Invoices.SalespersonPersonID	
	LEFT JOIN PickingCompletedOrders ON PickingCompletedOrders.InvoiceID = SalesTotals.InvoiceID
ORDER BY 
	SalesTotals.TotalSumm DESC
;

--Судя по выданным сообщениям (ниже), оптимизация не принесла значимых результатов. 
-- Возможно после многих проб, оптимизатор стал хорошо работать,  
-- результаты зависят отдругих запущенных программ, несколько раз запускал подряд получал разные результаты
-- особенно в части исходного неоптимизированного запроса: затраченное время менялось от несколких тысяч мс до 28 мс

--(8 rows affected)
--Таблица "OrderLines". Число просмотров 32, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 326, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 1, пропущено 0.
--Таблица "InvoiceLines". Число просмотров 32, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 322, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
--Таблица "Orders". Число просмотров 17, логических чтений 725, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 17, логических чтений 11994, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "People". Число просмотров 13, логических чтений 28, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 386 мс, затраченное время = 29 мс.

--(8 rows affected)
--Таблица "OrderLines". Число просмотров 32, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 326, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 1, пропущено 0.
--Таблица "InvoiceLines". Число просмотров 32, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 322, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
--Таблица "Orders". Число просмотров 17, логических чтений 725, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 17, логических чтений 11994, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "People". Число просмотров 10, логических чтений 28, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 48 мс, затраченное время = 30 мс.

--(8 rows affected)
--Таблица "OrderLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 163, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 1, пропущено 0.
--Таблица "InvoiceLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 161, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Orders". Число просмотров 1, логических чтений 692, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 2, логических чтений 11639, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "People". Число просмотров 1, логических чтений 11, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 47 мс, затраченное время = 48 мс.

--Completion time: 2022-12-05T14:03:06.5708521+07:00

