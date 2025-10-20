### Create GCP Project & BigQuery Setup
1. Create GCP project.
    - Go to https://console.cloud.google.com/ --> New Project --> name `ga4-attribution-pipeline`
2. Enable billing and APIs:
    - Enable **BigQuery API** and **IAM**.
3. Create a dataset for your dbt models:
    - In BigQuery console --> your project --> Create dataset:
        - Dataset ID: `ga4_models`
        - Data location: `US`
4. Confirm BigQuery access:
    - Open BigQuery and run the query:
    ```
    SELECT event_name, COUNT(*) AS cnt
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    GROUP BY event_name
    ORDER BY cnt DESC
    LIMIT 10;
    ```

If results show, then BigQuery access is confirmed. 

5. Create Service Account for local dbt runs:
    - GCP Console --> IAM & Admin --> Service Accounts --> Create Service Account:
        - Name: ```dbt-runner```
        - Roles: ```BigQuery User, BigQuery Data Editor, BigQuery Job User```
    - Create a JSON key and download. 
    - Set GOOGLE_APPLICATION_CREDENTIAL environment variable in System Variables with the JSON path.

### Local Dev Environment

1. Create Python virtual env and install dbt-bigquery
```
cd ~/ga4-attribution-pipeline
python3 -m venv venv
.\venv\Scripts\activate
pip install --upgrade pip
pip install dbt-bigquery
```

2. Initialize dbt project 
```
dbt init ga4_attribution
```

When prompted: 
- adaptor: ```bigquery```
- project id: ```ga4-attribution-pipeline```
- dataset: ```ga4_models```
- location: ```US```
- authenticaion: ```service-account``` (Provide the downloaded JSON path)

This creates a folder ```ga4_attribution``` with ```dbt_project.yml``` and ```models/``.

3. Test dbt connection
```
dbt debug
```

```ALL CHECKS PASSED``` message should be seen for a successful dbt connection. 

4. Create dbt models
- stg_ --> staging layer
- int_ --> intermediate layer
- mart_ --> mart and analytics layer

5. Run dbt models
```
dbt run
```

To run incrementally: 
```
dbt run -s stg_streamed_events+
```

### Streaming Demo Setup
##### 1. Run the streaming script
```
python streaming_demo/stream_events.py
```

Expected output:
```
Successfully initialized BigQuery client.
Inserted 20 records into `ga4_models.stream_events_buffer`.
```

##### 2. Run dbt to process streamed data
```
dbt run -s stg_streamed_events+
```

