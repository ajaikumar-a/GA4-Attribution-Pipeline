{{config(
    materialized = "incremental", 
    unique_key = "event_id", 
    partition_key = {"field": "event_date", "data_type": "date"}
)}}

-- Read buffer table
with buffer as (
    select 
        event_id, 
        event_timestamp, 
        user_pseudo_id, 
        event_name, 
        source, 
        medium, 
        campaign, 
        timestamp_micros(cast(event_timestamp as int64)) as event_ts, 
        date(timestamp_micros(cast(event_timestamp as int64))) as event_date
    from 
        `ga4-attribution-pipeline.ga4_models.stream_events_buffer`
)
select 
    *
from 
    buffer

{% if is_incremental() %}
    where event_id is not null and event_ts > (
        select coalesce(max(event_ts), timestamp('1970-01-01')) from {{this}}
    )
{% endif %}