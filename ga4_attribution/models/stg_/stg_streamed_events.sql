{{config(
    materialized = "incremental", 
    unique_key = "event_id", 
    partition_key = {"field": "event_timestamp", "data_type": "timestamp"}
)}}

-- Read buffer table
with buffer as (
    select 
        user_id, 
        user_pseudo_id, 
        event_id, 
        event_name, 
        event_timestamp, -- convert event_timestamp into readable format
        traffic_source, 
        traffic_medium, 
        campaign, 
        insert_timestamp
    from 
        `ga4-attribution-pipeline.ga4_models.stream_events_buffer`
)
select 
    *
from 
    buffer

    {% if is_incremental() %}
        where event_id is not null and event_timestamp > (
            (select max(event_timestamp) from {{this}})
        )
    {% endif %}