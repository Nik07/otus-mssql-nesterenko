/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

/*
TODO: Требования к проверке:
* оформление кода (ссылка на материал ...)
* линтеры (плагины IDE ...)
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters;

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".

Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

-- напишите здесь свое решение
SELECT 
  [StockItemID], 
  [StockItemName] 
FROM 
  Warehouse.StockItems 
WHERE 
  [StockItemName] like '%urgent%' 
  or [StockItemName] like 'Animal%';

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.

Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

-- напишите здесь свое решение
SELECT 
  s.SupplierID, 
  S.SupplierName 
FROM 
  Purchasing.Suppliers AS s
  LEFT JOIN Purchasing.PurchaseOrders AS p
    ON s.SupplierID = p.SupplierID 
WHERE 
  p.PurchaseOrderID IS NULL;

/*
3. Заказы (Orders) с товарами ценой (UnitPrice) более 100$
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).

Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ (10.01.2011)
* название месяца, в котором был сделан заказ (используйте функцию FORMAT или DATENAME)
* номер квартала, в котором был сделан заказ (используйте функцию DATEPART)
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

-- напишите здесь свое решение
-- Не понятно, зачем нужно сортировать по трети года. Эта сортировак излишняя, если есть сортировка по кварталу и дате
--вариант 1 
SELECT 
  O.OrderID, 
  CONVERT(varchar, O.OrderDate, 104) AS OrderDateFormat, 
  FORMAT(O.OrderDate, 'MMMM', 'Ru-ru') AS [MonthName], 
  DATEPART(QUARTER, O.OrderDate) AS [Quarter], 
  CEILING(
    DATEPART(MONTH, O.OrderDate) / 4.
  ) AS ThirdPartOfYear, 
  C.CustomerName 
FROM 
  Sales.Orders AS O 
  INNER JOIN Sales.OrderLines AS OL 
    ON O.OrderID = OL.OrderID
	  AND (
		OL.UnitPrice > 100 
		OR OL.Quantity > 20 
	  )
  INNER JOIN Sales.Customers AS C 
    ON O.CustomerID = C.CustomerID 
ORDER BY 
  [Quarter], 
  ThirdPartOfYear, 
  O.OrderDate;

  --вариант 2
SELECT 
  O.OrderID, 
  CONVERT(varchar, O.OrderDate, 104) AS OrderDateFormat, 
  FORMAT(O.OrderDate, 'MMMM', 'Ru-ru') AS [MonthName], 
  DATEPART(QUARTER, O.OrderDate) AS [Quarter], 
  CEILING(
    DATEPART(MONTH, O.OrderDate) / 4.
  ) AS ThirdPartOfYear, 
  C.CustomerName 
FROM 
  Sales.Orders AS O 
  INNER JOIN Sales.OrderLines AS OL 
    ON O.OrderID = OL.OrderID
	  AND (
		OL.UnitPrice > 100 
		OR OL.Quantity > 20 
	  )
  INNER JOIN Sales.Customers AS C 
    ON O.CustomerID = C.CustomerID 
ORDER BY 
  [Quarter], 
  ThirdPartOfYear, 
  O.OrderDate 
  OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY;


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).

Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

-- напишите здесь свое решение
SELECT 
  dm.DeliveryMethodName, 
  po.ExpectedDeliveryDate, 
  s.SupplierName, 
  p.FullName 
FROM 
  Purchasing.Suppliers AS s 
  INNER JOIN Purchasing.PurchaseOrders AS po 
    ON po.SupplierID = s.SupplierID 
	  AND YEAR(po.ExpectedDeliveryDate) = 2013 
      AND MONTH(po.ExpectedDeliveryDate) = 1  -- (po.ExpectedDeliveryDate between '20130101' and '20130131')
	  AND po.IsOrderFinalized = 1
  INNER JOIN Application.DeliveryMethods AS dm 
    ON dm.DeliveryMethodID = po.DeliveryMethodID 
	  AND 
        dm.DeliveryMethodName IN (
          'Air Freight', 'Refrigerated Air Freight'
        )
  INNER JOIN Application.People AS p 
    ON p.PersonID = po.ContactPersonID 
  ;


/*
5. Десять последних продаж (по дате продажи - InvoiceDate) с именем клиента (клиент - CustomerID) и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.

Вывести: ИД продажи (InvoiceID), дата продажи (InvoiceDate), имя заказчика (CustomerName), имя сотрудника (SalespersonFullName)
Таблицы: Sales.Invoices, Sales.Customers, Application.People.
*/

-- напишите здесь свое решение
SELECT TOP(10)
  i.InvoiceID AS [ИД продажи], 
  i.InvoiceDate AS [Дата продажи], 
  c.CustomerName AS [Имя заказчика], 
  p.FullName AS [Имя сотрудника] 
FROM 
  Sales.Invoices AS i 
  INNER JOIN Sales.Customers AS c 
    ON i.CustomerID = c.CustomerID 
  INNER JOIN Application.People AS p 
    ON i.SalespersonPersonID = p.PersonID 
ORDER BY 
  i.InvoiceDate DESC, 
  i.InvoiceID  -- добавил для однозначности
  ;

/*
6. Все ид и имена клиентов (клиент - CustomerID) и их контактные телефоны (PhoneNumber),
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems, имена клиентов и их контакты в таблице Sales.Customers.

Вывести: todo
Таблицы: Sales.Invoices, Sales.InvoiceLines, Sales.Customers, Warehouse.StockItems.
*/

-- напишите здесь свое решение
SELECT DISTINCT 
  c.CustomerID, 
  c.CustomerName, 
  c.PhoneNumber 
FROM 
  Sales.Customers AS c
  INNER JOIN Sales.Invoices AS i
    ON i.CustomerID = c.CustomerID 
  INNER JOIN Sales.InvoiceLines AS il 
    ON il.InvoiceID = i.InvoiceID    
  INNER JOIN Warehouse.StockItems AS si 
    ON il.StockItemID = si.StockItemID 
      AND si.StockItemName = 'Chocolate frogs 250g'
;
