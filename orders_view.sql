--Значение в поле status должно соответствовать последнему по времени статусу из таблицы production.OrderStatusLog
create view de.analysis.orders as
select		order_id ,status_id
from		(select		order_id ,status_id ,dttm
						,max(dttm) over(partition by order_id) as max_dt
			from		de.production.OrderStatusLog
			order by	order_id
			) as tbl
where		dttm = max_dt
;