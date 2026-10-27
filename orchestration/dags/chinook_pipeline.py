from datetime import timedelta
import time
import requests
import pendulum
from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

# Variables de Airbyte Local expuesto vía túnel
AIRBYTE_LOCAL_URL = Variable.get("AIRBYTE_LOCAL_URL")
AIRBYTE_CONNECTION_ID = Variable.get("AIRBYTE_CONNECTION_ID")
AIRBYTE_USERNAME = Variable.get("AIRBYTE_USERNAME")
AIRBYTE_PASSWORD = Variable.get("AIRBYTE_PASSWORD")

# Variables de dbt Cloud
DBT_HOST = Variable.get("DBT_HOST")
DBT_ACCOUNT_ID = Variable.get("DBT_ACCOUNT_ID")
DBT_JOB_ID_PLATA = Variable.get("DBT_JOB_ID_PLATA")
DBT_JOB_ID_ORO = Variable.get("DBT_JOB_ID_ORO")
DBT_API_TOKEN = Variable.get("DBT_API_TOKEN")


def trigger_airbyte_sync(**context):
    url_base = AIRBYTE_LOCAL_URL.rstrip("/")
    headers = {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "69420",
    }

    print(f"Obteniendo access token de Airbyte vía: {url_base}")

    # 1. Obtener Bearer Token usando el Client ID y Client Secret
    token_resp = requests.post(
        f"{url_base}/api/v1/applications/token",
        headers=headers,
        json={
            "client_id": AIRBYTE_USERNAME,
            "client_secret": AIRBYTE_PASSWORD
        },
        timeout=30,
    )
    token_resp.raise_for_status()
    access_token = token_resp.json().get("access_token")

    auth_headers = {
        **headers,
        "Authorization": f"Bearer {access_token}"
    }

    print("Iniciando sync en Airbyte Local...")

    # 2. Disparar el trabajo con el Bearer Token
    sync_resp = requests.post(
        f"{url_base}/api/v1/connections/sync",
        headers=auth_headers,
        json={"connectionId": AIRBYTE_CONNECTION_ID},
        timeout=60,
    )
    sync_resp.raise_for_status()

    job_info = sync_resp.json().get("job", {})
    job_id = job_info.get("id")
    print(f"Airbyte Local Job iniciado con ID: {job_id}")

    # 3. Monitorear el progreso
    for _ in range(120):
        time.sleep(15)

        status_resp = requests.post(
            f"{url_base}/api/v1/jobs/get",
            headers=auth_headers,
            json={"id": job_id},
            timeout=30,
        )
        status_resp.raise_for_status()

        status = status_resp.json().get("job", {}).get("status")
        print(f"Estado Airbyte Local: {status}")

        if status in ("succeeded", "successful"):
            print("Airbyte sync completado con éxito.")
            return

        if status in ("failed", "cancelled"):
            raise Exception(f"Airbyte sync falló con estado: {status}")

    raise Exception("Airbyte sync excedió el tiempo límite (timeout)")

def run_dbt_job(job_id, job_name):
    headers = {
        "Authorization": f"Token {DBT_API_TOKEN}",
        "Content-Type": "application/json",
    }

    run_url = (
        f"{DBT_HOST.rstrip('/')}/api/v2/accounts/"
        f"{DBT_ACCOUNT_ID}/jobs/"
        f"{job_id}/run/"
    )

    run_resp = requests.post(
        run_url,
        headers=headers,
        json={"cause": "Triggered by Airflow"},
        timeout=60,
    )

    print(f"[{job_name}] status: {run_resp.status_code}")
    print(f"[{job_name}] response: {run_resp.text}")
    run_resp.raise_for_status()

    run_id = run_resp.json()["data"]["id"]
    print(f"[{job_name}] run iniciado: {run_id}")

    status_url = (
        f"{DBT_HOST.rstrip('/')}/api/v2/accounts/"
        f"{DBT_ACCOUNT_ID}/runs/"
        f"{run_id}/"
    )

    for _ in range(60):
        time.sleep(30)

        status_resp = requests.get(
            status_url,
            headers=headers,
            timeout=30,
        )
        status_resp.raise_for_status()

        status = status_resp.json()["data"]["status_humanized"]
        print(f"[{job_name}] status: {status}")

        if status == "Success":
            print(f"[{job_name}] OK")
            return

        if status in ("Error", "Cancelled", "Failed"):
            raise Exception(f"[{job_name}] falló: {status}")

    raise Exception(f"[{job_name}] timeout")


def trigger_dbt_plata(**context):
    run_dbt_job(DBT_JOB_ID_PLATA, "PLATA")


def trigger_dbt_oro(**context):
    run_dbt_job(DBT_JOB_ID_ORO, "ORO")


local_tz = pendulum.timezone("America/La_Paz")

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "start_date": pendulum.datetime(2024, 1, 1, tz=local_tz),
}

with DAG(
    dag_id="chino",
    default_args=default_args,
    description="Pipeline ELT: Airbyte Local - dbt PLATA - dbt ORO",
    schedule="15 16 * * *",
    catchup=False,
    tags=["la_paz", "elt"],
) as dag:

    inicio = EmptyOperator(task_id="inicio")

    sync_airbyte = PythonOperator(
        task_id="sync_airbyte_bronce",
        python_callable=trigger_airbyte_sync,
    )

    dbt_plata = PythonOperator(
        task_id="dbt_plata",
        python_callable=trigger_dbt_plata,
    )

    dbt_oro = PythonOperator(
        task_id="dbt_oro",
        python_callable=trigger_dbt_oro,
    )

    fin = EmptyOperator(task_id="fin")

    inicio >> sync_airbyte >> dbt_plata >> dbt_oro >> fin