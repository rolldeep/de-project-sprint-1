/*
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
*/

insert into analysis.tmp_rfm_recency

--подготавливаем данные для рассчёта метрик recency ,frequency ,monetary_value
with source_tbl as (
select 		user_id ,order_id, order_ts ,cast(order_ts as date) as order_dt , current_date - cast(order_ts as date) as delta_dt
			,max(order_ts) over (partition by user_id) as max_dt
			,payment
from 		de.production.orders
where 		status = 4
--			and user_id = 999
)

--считаем recency,  берем дату последнего заказа
,recency as (
select 		user_id ,delta_dt as recency
from		source_tbl
where		max_dt = order_ts
)

--берем всех клиентов и мерджим к ним метрики
,prev_tbl as (
select		t1.id as user_id, t2.recency ,count(distinct t3.order_id) as frequency ,sum(coalesce (t3.payment, 0)) as monetary_value
from		(select id from de.production.users) as t1
left join	recency as t2 on t1.id = t2.user_id
left join	source_tbl as t3 on t1.id = t3.user_id
--where		t2.recency is null
group by 	t1.id, t2.recency
)

--разбиваем на группы
,batch as (
select 		percentile_disc(0.2) within group (order by recency asc) as r_20
			,percentile_disc(0.4) within group (order by recency asc) as r_40
			,percentile_disc(0.6) within group (order by recency asc) as r_60
			,percentile_disc(0.8) within group (order by recency asc) as r_80
		
			,percentile_disc(0.2) within group (order by frequency asc) as f_20
			,percentile_disc(0.4) within group (order by frequency asc) as f_40
			,percentile_disc(0.6) within group (order by frequency asc) as f_60
			,percentile_disc(0.8) within group (order by frequency asc) as f_80
			
			,percentile_disc(0.2) within group (order by monetary_value asc) as m_20
			,percentile_disc(0.4) within group (order by monetary_value asc) as m_40
			,percentile_disc(0.6) within group (order by monetary_value asc) as m_60
			,percentile_disc(0.8) within group (order by monetary_value asc) as m_80	
from		prev_tbl
)

,rfm as (
select		t1.user_id ,t1.recency ,t1.frequency ,t1.monetary_value
			,case
				when t1.recency <= r_20 then 5
				when t1.recency <= r_40 then 4
				when t1.recency <= r_60 then 3
				when t1.recency <= r_80 then 2
				else 1
			end as r
			,case
				when t1.frequency <= f_20 then 1
				when t1.frequency <= f_40 then 2
				when t1.frequency <= f_60 then 3
				when t1.frequency <= f_80 then 4
				else 5
			end as f
			,case
				when t1.monetary_value <= m_20 then 1
				when t1.monetary_value <= m_40 then 2
				when t1.monetary_value <= m_60 then 3
				when t1.monetary_value <= m_80 then 4
				else 5
			end as m
from		prev_tbl as t1
cross join	batch as t2
)

select user_id ,r as  recency from rfm;