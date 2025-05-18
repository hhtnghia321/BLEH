from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from openai import OpenAI
from pathlib import Path
import os

from Models.message import Message

load_dotenv()  # Load variables from .env

api_key = os.getenv("OPENAI_API_KEY")

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

client = OpenAI(
    api_key = api_key,
    base_url="https://openrouter.ai/api/v1",
)
BASE_DIR = str(Path(__file__).resolve().parent)

app.mount("/static", StaticFiles(directory=BASE_DIR + "/static"), name="static")

# Serve index.html at root
@app.get("/", response_class=HTMLResponse)
async def get_index():
    html_path = Path(BASE_DIR + "/index.html")
    return HTMLResponse(content=html_path.read_text(), status_code=200)

@app.post("/chat")
async def chat(msg: Message):
    # response = client.responses.create(
    #     model="deepseek/deepseek-r1:free",
    #     input=[
    #         {"role": "user", "content":  msg.message,},
    #     ],
    # )
    completion = client.chat.completions.create(
        extra_headers={
            # "HTTP-Referer": "<YOUR_SITE_URL>", # Optional. Site URL for rankings on openrouter.ai.
            # "X-Title": "<YOUR_SITE_NAME>", # Optional. Site title for rankings on openrouter.ai.
        },
        extra_body={},
        model="deepseek/deepseek-r1:free",
        messages=[
            {
            "role": "user",
            "content": msg.message
            }
        ]
        )
    return {"reply": completion.choices[0].message.content}
