{{config(materialized = "view")}}

-- Staging model: Flatten commonly used fields
with events as (
  select 
    event_date, 
    event_timestamp, 
    event_name, 
    user_id, 
    user_pseudo_id, 
    traffic_source, 
    event_params, 
    (select value.string_value from unnest(event_params) where key = 'event_id') as event_id, 
    (select value.string_value from unnest(event_params) where key = 'page_location') as page_location, 
    (select value.string_value from unnest(event_params) where key = 'link_id') as link_id, 
    (select value.string_value from unnest(event_params) where key = 'engagement_time_msec') as engagement_time_msec, 
    (select value.string_value from unnest(event_params) where key = 'campaign') as campaign
  from 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
--   where 
--     _TABLE_SUFFIX between '20201101' and '20210131'
)
select 
  event_date, 
  event_timestamp, 
  event_name, 
  user_id, 
  user_pseudo_id, 
  coalesce((select value.string_value from unnest(event_params) where key = 'event_id'), 
            concat(user_pseudo_id, '-', cast(event_timestamp as string))) as event_id,
  traffic_source.source as traffic_source, 
  traffic_source.medium as traffic_medium, 
  campaign,
  page_location, 
  link_id, 
  engagement_time_msec
from 
  events