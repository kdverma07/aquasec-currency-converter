from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
import requests
import os

app = FastAPI()
templates = Jinja2Templates(directory="templates")

API_KEY = os.getenv("OPENEXCHANGERATES_APP_ID")
if not API_KEY:
    raise Exception("OPENEXCHANGERATES_APP_ID environment variable not set")

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    currencies = ["USD", "EUR", "GBP", "INR", "JPY", "AUD", "CAD"]
    return templates.TemplateResponse("index.html", {"request": request, "currencies": currencies, "result": None})

@app.post("/convert", response_class=HTMLResponse)
async def convert(request: Request,
                  from_currency: str = Form(...),
                  to_currency: str = Form(...),
                  amount: float = Form(...)):
    url = f"https://openexchangerates.org/api/latest.json?app_id={API_KEY}"
    response = requests.get(url)

    if response.status_code != 200:
        result = f"Error fetching exchange rate. Status code: {response.status_code}"
    else:
        data = response.json()
        rates = data.get('rates', {})
        if from_currency not in rates or to_currency not in rates:
            result = "Error: Currency not supported."
        else:
            try:
                # Convert amount from 'from_currency' to USD, then USD to 'to_currency'
                amount_in_usd = amount / rates[from_currency]
                converted_amount = amount_in_usd * rates[to_currency]
                result = f"{amount} {from_currency} = {converted_amount:.2f} {to_currency}"
            except Exception as e:
                result = f"Conversion error: {str(e)}"

    currencies = ["USD", "EUR", "GBP", "INR", "JPY", "AUD", "CAD"]
    return templates.TemplateResponse("index.html", {
        "request": request,
        "currencies": currencies,
        "result": result
    })
