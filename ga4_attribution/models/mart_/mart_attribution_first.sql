{{config(materialized = "table")}}

-- Get first sessions details from intermediate model
with sessions as (
select 
  user_key, 
  session_number, 
  session_start_ts, 
  first_source, 
  first_medium, 
  first_campaign
from 
  {{ref('int_sessions')}}
)
select 
  date(session_start_ts) as session_date, 
  coalesce(first_source, '(organic)') as source, 
  coalesce(first_medium, '(none)') as medium, 
  count(*) as sessions
from 
  sessions
group by 
  1, 2, 3
order by 
  session_date desc