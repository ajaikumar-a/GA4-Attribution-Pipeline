## GA4 Real-Time Attribution Pipeline
End-to-end Google Analytics (GA4) attribution data pipeline built using Google BigQuery, dbt, and a Python streaming simulator.

This project replicates Google Analytics 4 (GA4) event processing for attribution analysis — including ETL modeling, real-time streaming, and dashboard visualization.

#### Project Overview
The pipeline simulates user events flowing from a GA4 source dataset, processes them through dbt models, and produces final attribution marts used in a Looker dashboard.

Layers

stg_ (Staging) - Cleans and standardizes raw GA4 data (or streamed demo events)
int_ (Intermediate) - Sessionizes user events
mart_ (Analytics Mart) - Generates attribution metrics (first-touch, last-touch)

This project includes a Python-base streaming demo to insert live events into BigQuery and continuously update the dashboard. 

#### Architecture


BigQuery dataset: ga4-attribution-pipeline.ga4_models
GA4 public dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*

#### Prerequisites
Make sure you have the following:
- Google Cloud Project with BigQuery and Service Account access
- Python 3.9+
- `dbt-bigquery` installed
- Google Cloud SDK (`gcloud`)
- Access to public GA4 dataset

#### Real-time Streaming Demo

###### 1. Run streaming script
File: `streaming_demo/stream_events.py`

```python streaming_demo/stream_events.py```

This script inserts demo events into ```ga4-attribution-pipeline.ga4_models.stream_events_buffer```


###### 2. Process new streamed data
Run the dbt model to process new stream events.

```dbt run -s stg_streamed_events.sql+```

This will: 
- Run dbt models downstream starting from ```stg_streamed_events.sql```. 
- Pull data from ```stream_events_buffer``` table in BigQuery.
- Append to ```stg_streamed_events```.
- Recalculate attribution metrics.

#### Dashboard
You can connect your BI tool(Eg: Looker Studio, Power BI, Tableau, etc.) to BigQuery.

Suggested tables:
```mart_attribution_first```
```mart_attribution_last```

Common metrics:
- Sessions by source
- First-touch and Last-touch sessions
- Last 1 month sessions timeline

Dashboard link: https://lookerstudio.google.com/reporting/e26cc577-e1d1-484c-8c29-2354c0d029b5

#### Automation
The full pipeline can be scheduled using Windows Task Scheduler.

Create ```schedule.bat```

```
@echo off
REM ========SETUP ENVIRONMENT ==========
REM Activate virtual environment
call "D:\Data_Engineering\Projects\GA4_Attribution_Pipeline\venv\Scripts\activate.bat"

REM Move to project directory
cd /d "D:\Data_Engineering\Projects\GA4_Attribution_Pipeline\"

REM Run Python script
echo Running Python script....
python "streaming_demo/stream_events.py"

REM Run dbt models
echo Running dbt models....
cd /d "D:\Data_Engineering\Projects\GA4_Attribution_Pipeline\ga4_attribution\models\"
dbt run -s stg_streamed_events.sql+

REM Finish
echo Job finished successfully at %date% %time%.
```
Then add a daily trigger in Task Scheduler. 

#### Cost & Monitoring

| Component         | Description                     | Recommendation                     |
|-------------------|----------------------------------|------------------------------------|
| BigQuery Storage | Charges for dataset tables        | Use partitioning & clustering       |
| BigQuery Queries | Charges per query run by dbt      | Use incremental models              |
| Streaming Inserts | $0.01 per 200 MB of streamed data | For demo, negligible                |
| Monitoring       | Use Cloud Logging / dbt logs      | Monitor query costs in GCP console  |

#### Key Datasets

| Dataset                  | Description                              |
|---------------------------|------------------------------------------|
| stg_ga4_events        | Historical GA4 data from public dataset  |
| stream_events_buffer  | Streaming demo buffer table              |
| stg_streamed_events   | Cleansed streamed data                   |
| int_sessions          | Sessionized user events                  |
| mart_attribution_first| First-touch attribution metrics          |
| mart_attribution_last | Last-touch attribution metrics           |

#### Learnings 
- Modular dbt design enables scalable attribution pipelines.
- Incremental models make the pipeline cost-efficient.
- Real-time ingestion supports live dashboards.
- Can be extended with Google Pub/Sub or Kafka for production-level streaming.