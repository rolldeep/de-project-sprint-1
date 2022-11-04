insert into analysis.dm_rfm_segments

--создаём таблицу со всеми user_id к которой будем мержить метрики
select		u.user_id , r.recency  ,f.frequency  ,m.monetary_value 
from		(select user_id from analysis.tmp_rfm_frequency
				union
			select user_id from analysis.tmp_rfm_monetary_value
				union
			select user_id from analysis.tmp_rfm_recency
			) as u
left join	analysis.tmp_rfm_frequency as f on u.user_id = f.user_id
left join	analysis.tmp_rfm_monetary_value as m on u.user_id = m.user_id
left join	analysis.tmp_rfm_recency as r on u.user_id = r.user_id
---------------------------------------------------------------------------------------
| user_id | recency | frequency | monetary_value |
| 0 | 1 | 3 | 4 |
| 1 | 4 | 3 | 3 |
| 2 | 2 | 3 | 5 |
| 3 | 2 | 3 | 3 |
| 4 | 4 | 3 | 3 |
| 5 | 5 | 5 | 5 |
| 6 | 1 | 3 | 5 |
| 7 | 4 | 2 | 2 |
| 8 | 1 | 1 | 3 |
| 9 | 1 | 2 | 2 |
| 10 | 3 | 4 | 2 |