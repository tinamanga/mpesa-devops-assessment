from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/payments")
def payments():
    return {"message": "Payment endpoint working"}


@app.post("/payments")
def create_payment():
    return {"status": "payment created"}