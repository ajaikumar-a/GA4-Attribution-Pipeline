{{config(materialized = "view")}}

-- Get events from staging model
with int_events as (
  select 
    user_id, 
    user_pseudo_id, 
    event_id, 
    event_name, 
    event_timestamp as event_ts,
    traffic_source, 
    traffic_medium, 
    campaign
  from 
    {{ref('stg_streamed_events')}}
), 
-- Get previous event details
lag_events as (
select 
  *, 
  lag(event_ts) over(partition by coalesce(user_id, user_pseudo_id) order by event_ts) as prev_event_ts
from 
  int_events
), 
-- Calculate session numbers for each user with a 30 minute session timeout
sessionized as (
select 
  *, 
  sum(case when prev_event_ts is null or timestamp_diff(event_ts, prev_event_ts, minute) > 30 then 1 else 0 end)
    over(partition by coalesce(user_id, user_pseudo_id) order by event_ts) as session_number
from 
  lag_events
),
-- Session-wise summary
sessions as (
  select 
    coalesce(user_id, user_pseudo_id) as user_key, 
    session_number, 
    min(event_ts) as session_start_ts, 
    max(event_ts) as session_end_ts, 
    array_agg(struct(event_ts, event_id, traffic_source, traffic_medium, event_name, campaign) order by event_ts) as events
  from 
    sessionized 
  group by 
    1, 2
)
select 
  user_key, 
  session_number, 
  session_start_ts, 
  session_end_ts, 
  -- Get the first and last traffic source and medium
  (select e.traffic_source from unnest(events) e order by e.event_ts limit 1) as first_source,
  (select e.traffic_medium from unnest(events) e order by e.event_ts limit 1) as first_medium,
  (select e.traffic_source from unnest(events) e order by e.event_ts desc limit 1) as last_source,
  (select e.traffic_medium from unnest(events) e order by e.event_ts desc limit 1) as last_medium,
  (select e.campaign from unnest(events) e order by e.event_ts limit 1) as first_campaign,
  (select e.campaign from unnest(events) e order by e.event_ts limit 1) as last_campaign,
  events
from 
  sessions