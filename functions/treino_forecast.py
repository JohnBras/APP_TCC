# ==========================================================
# functions/treino_forecast.py
# ==========================================================
import pandas as pd                      # type: ignore
from sklearn.linear_model import LinearRegression          # type: ignore
from datetime import datetime, timedelta, timezone
from google.cloud import firestore

_db = firestore.Client()
SALES_COLLECTION = "order"


def _iter_rows(window_days: int):
    """
    Gera dicionários {product_id, quantity, date} a partir de /order,
    percorrendo cada item da lista 'items'.
    """
    end   = datetime.now(timezone.utc)            # tz-aware
    start = end - timedelta(days=window_days)

    q = (_db.collection(SALES_COLLECTION)
             .where("date", ">=", start))
    for doc_snap in q.stream():
        order = doc_snap.to_dict()

        ts = order.get("date")
        if not ts:                      # sem data → pula
            continue

        # Firestore Timestamp → datetime & torna tz-naive
        order_date = ts.replace(tzinfo=None)

        for it in order.get("items", []):
            yield {
                "product_id": it.get("pid"),
                "quantity":   float(it.get("quantity", 0)),
                "date":       order_date
            }


def train_and_predict(window_days: int):
    """
    Treina regressão linear por produto e devolve lista:
    [{ product_id, predicted, historical_avg }, …]
    """
    rows = list(_iter_rows(window_days))
    print(f"⚙️ rows len = {len(rows)}")

    if not rows:
        return []

    df = pd.DataFrame(rows)
    results = []

    for pid, g in df.groupby("product_id"):
        g = g.sort_values("date")
        start0 = g["date"].min()
        # dias desde o 1º registro
        X = ((g["date"] - start0).dt.days).values.reshape(-1, 1)
        y = g["quantity"].values

        model = LinearRegression()
        model.fit(X, y)

        pred = float(model.predict([[window_days]])[0])
        hist = float(y.mean())

        results.append({
            "product_id": pid,
            "predicted": max(pred, 0.0),
            "historical_avg": hist
        })

    print(f"⚙️ results len = {len(results)}")
    return results


def predict_sales_total(window_days: int) -> float:
    """Soma todas as previsões de train_and_predict()."""
    return float(sum(r["predicted"] for r in train_and_predict(window_days)))
