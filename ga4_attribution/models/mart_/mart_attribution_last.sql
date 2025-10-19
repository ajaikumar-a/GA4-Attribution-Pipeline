{{config(materialized = "table")}}

-- Get last sessions details from intermediate model
with sessions as (
select 
  user_key, 
  session_number, 
  session_end_ts, 
  last_source, 
  last_medium
from 
  {{ref('int_sessions')}}
)
select 
  date(session_end_ts) as session_date, 
  coalesce(last_source, '(organic)') as source, 
  coalesce(last_medium, '(none)') as medium, 
  count(*) as sessions
from 
  sessions
group by 
  1, 2, 3
order by 
  session_date desc