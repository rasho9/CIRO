from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
title="CIRO Crisis Orchestration API",
version="1.0.0",
)

app.add_middleware(
CORSMiddleware,
allow_origins=["*"],
allow_methods=["*"],
allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "CIRO Backend Running Successfully"
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy"
    }
