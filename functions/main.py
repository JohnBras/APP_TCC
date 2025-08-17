# ======================================
# functions/main.py
# ======================================
# Google Cloud Functions (Python) para treinar e servir previsões ML
# Dependências: functions/treino_forecast.py, google-cloud-firestore, google-cloud-pubsub, functions-framework

import os
import json
from datetime import datetime, timezone

from treino_forecast import train_and_predict, predict_sales_total
from google.cloud import firestore

# Inicializa Firestore
db = firestore.Client()

# Parâmetros padrão de agendamento e janela
DEFAULT_WINDOW_DAYS = int(os.getenv('DEFAULT_WINDOW_DAYS', '28'))

# --------------------------------------
# Função agendada para retreinar e persistir previsões
# Executar diariamente via Pub/Sub scheduler ou Cloud Scheduler
# --------------------------------------
def schedule_forecast_train(event, context):
    """
    Triggered by Cloud Scheduler daily.
    Re-treina modelo com DEFAULT_WINDOW_DAYS e grava previsões no Firestore.
    """
    window = DEFAULT_WINDOW_DAYS
    # Obter previsões de demanda por produto
    demand_results = train_and_predict(window)
    # Exemplo: demand_results = [ {'product_id': 'p1', 'predicted': 10.5, 'historical_avg': 8.3}, ... ]
    batch = db.batch()
    for item in demand_results:
        doc_ref = db.collection('forecasts').document(item['product_id'])
        batch.set(doc_ref, {
            'type': 'demand',
            'predicted': item['predicted'],
            'historical_average': item['historical_avg'],
            'generated_at': datetime.now(timezone.utc)
        }, merge=True)
    # Previsão de vendas totais
    sales_pred = predict_sales_total(window)
    batch.set(db.collection('forecasts').document('total_sales'), {
        'type': 'sales',
        'predicted': sales_pred,
        'historical_average': None,
        'generated_at': datetime.now(timezone.utc)
    }, merge=True)
    batch.commit()
    return ('Forecasts updated', 200)

# --------------------------------------
# Função HTTP para obter previsões sob demanda
# --------------------------------------
def predict_demand(request):
    """
    HTTP endpoint para retornar previsões de demanda.
    Recebe JSON: { 'window': 7 }
    Retorna: [ { 'product_id': ..., 'predicted': ..., 'historical_avg': ... }, ... ]
    """
    request_json = request.get_json(silent=True) or {}
    window = int(request_json.get('window', DEFAULT_WINDOW_DAYS))
    results = train_and_predict(window)
    # Retornar JSON
    return (json.dumps(results), 200, {'Content-Type': 'application/json'})

# --------------------------------------
# Função HTTP para obter previsão de vendas
# --------------------------------------
def predict_sales(request):
    """
    HTTP endpoint para retornar previsão de vendas totais.
    Opcional: recebe 'window', mas pode usar fixo DEFAULT_WINDOW_DAYS.
    Retorna: { 'id': 'total_sales', 'predicted': ..., 'historical_avg': None }
    """
    request_json = request.get_json(silent=True) or {}
    window = int(request_json.get('window', DEFAULT_WINDOW_DAYS))
    pred = predict_sales_total(window)
    response = {
        'id': 'total_sales',
        'predicted': pred,
        'historical_average': None
    }
    return (json.dumps(response), 200, {'Content-Type': 'application/json'})

# Note:
# - package=functions for treino_forecast import
# - deploy: 
# gcloud functions deploy schedule_forecast_train \
# --source=functions \
#   --trigger-topic=forecast-topic \
#   --runtime=python39 \
#   --region=us-central1 \
#   --entry-point=schedule_forecast_train

# gcloud functions deploy predict_demand \
#   --source=functions \
#   --trigger-http --allow-unauthenticated \
#   --runtime=python39 \
#   --region=us-central1 \
#   --entry-point=predict_demand

# gcloud functions deploy predict_sales \
#   --source=functions \
#   --trigger-http --allow-unauthenticated \
#   --runtime=python39 \
#   --region=us-central1 \
#   --entry-point=predict_sales
