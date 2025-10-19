#!/usr/bin/env/ python3

# Streaming demo: Insert 10 events into BigQuery streaming buffer table

from google.cloud import bigquery
import uuid, time, random
from datetime import datetime, timedelta

# BigQuery buffer table details
PROJECT = 'ga4-attribution-pipeline'
DATASET = 'ga4_models'
TABLE = 'stream_events_buffer'
BQ_TABLE = f"{PROJECT}.{DATASET}.{TABLE}"

# Initialize BigQuery client
client = bigquery.Client(project = PROJECT)
print("Successfully initialized BigQuery client.")

start_ts = datetime.now() - timedelta(days = 5)
time_increment = timedelta(minutes = 1)

# Function: Generate demo events
def generate_events(i):
    event_ts = str(start_ts + (i * time_increment)) # adding incremented timstamps for each event
    return {
        "user_id": f"user_{random.randint(20, 30)}", 
        "user_pseudo_id": f"pseudo_user_{random.randint(20, 30)}", 
        "event_id": str(uuid.uuid4()), 
        "event_name": random.choice(["page_view", "purchase", "scroll", "add_to_cart"]), 
        "event_timestamp": event_ts, 
        "traffic_source": random.choice(["google", "facebook", "newsletter", "direct"]), 
        "traffic_medium": random.choice(["organic", "cpc", "email", "(none)"]), 
        "campaign": "demo_campaign", 
        "insert_timestamp": event_ts
    }


# Function: Insert stream events into BigQuery table
def insert_stream_events(n = 100, delay = 0.5):
    rows = [generate_events(i) for i in range(n)]
    errors = client.insert_rows_json(BQ_TABLE, rows)
    if errors:
        print("Errors: ", errors)
    else:
        print(f"Inserted {len(rows)} records into {BQ_TABLE}.")


if __name__ == '__main__':
    insert_stream_events()