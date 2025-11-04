"""
FastAPI Backend for Godot AI Game
Uses Hugging Face Inference Providers API (OpenAI-compatible endpoint).
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import os
import requests
import sys

app = FastAPI(title="Godot AI Game Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PromptRequest(BaseModel):
    prompt: str

class PromptResponse(BaseModel):
    response: str
    model_loaded: bool = True

# Hugging Face Inference Providers API settings
HF_API_KEY = os.getenv("HF_API_KEY", "").strip()
# Using OpenAI-compatible chat completions endpoint
# Try using HF Inference provider's own models - these should be available
HF_MODEL = "meta-llama/Llama-3.2-1B-Instruct:fastest"  # :fastest selects fastest provider
HF_API_URL = "https://router.huggingface.co/v1/chat/completions"

# Debug: Check if API key is loaded (don't print the actual key)
if HF_API_KEY:
    print(f"HF_API_KEY loaded (length: {len(HF_API_KEY)})", file=sys.stderr)
    print(f"HF_API_KEY loaded (length: {len(HF_API_KEY)})")  # Also print to stdout
else:
    print("WARNING: HF_API_KEY not found in environment variables", file=sys.stderr)
    print("WARNING: HF_API_KEY not found in environment variables")  # Also print to stdout

@app.get("/")
async def root(msg: Optional[str] = None):
    """Health check and text generation endpoint"""
    if not msg:
        return {"status": "online", "model_loaded": True, "message": "AI Game Backend is running"}
    
    return await generate_text(PromptRequest(prompt=msg))

async def generate_text(request: PromptRequest) -> PromptResponse:
    """Generate AI response using Hugging Face Inference API"""
    print(f"generate_text called with prompt: {request.prompt[:50]}...", file=sys.stderr)
    
    if not request.prompt or len(request.prompt.strip()) == 0:
        raise HTTPException(status_code=400, detail="Prompt cannot be empty")
    
    if len(request.prompt) > 500:
        raise HTTPException(status_code=400, detail="Prompt too long (max 500 characters)")
    
    if not HF_API_KEY:
        error_msg = "Hugging Face API key not configured. Set HF_API_KEY secret in Space settings."
        print(f"ERROR: {error_msg}", file=sys.stderr)
        raise HTTPException(status_code=500, detail=error_msg)
    
    try:
        # OpenAI-compatible format using messages array
        headers = {
            "Authorization": f"Bearer {HF_API_KEY}",
            "Content-Type": "application/json"
        }
        payload = {
            "model": HF_MODEL,
            "messages": [
                {
                    "role": "system",
                    "content": "You are a friendly and helpful AI assistant. Keep your responses concise and conversational."
                },
                {
                    "role": "user",
                    "content": request.prompt
                }
            ],
            "max_tokens": 100,
            "temperature": 0.7
        }
        
        print(f"Calling Inference Providers API: {HF_API_URL}", file=sys.stderr)
        print(f"Model: {HF_MODEL}", file=sys.stderr)
        print(f"Prompt: {request.prompt[:100]}...", file=sys.stderr)
        
        response = requests.post(HF_API_URL, headers=headers, json=payload, timeout=60)
        
        if response.status_code != 200:
            error_detail = response.text[:500] if response.text else "Unknown error"
            error_msg = f"Inference Providers API error ({response.status_code}): {error_detail}"
            print(f"ERROR: {error_msg}", file=sys.stderr)
            print(f"ERROR: {error_msg}")  # Also print to stdout
            print(f"Response headers: {dict(response.headers)}", file=sys.stderr)
            raise HTTPException(status_code=500, detail=error_msg)
        
        result = response.json()
        
        # Handle OpenAI-compatible response format
        # Response structure: {"choices": [{"message": {"content": "..."}}]}
        if isinstance(result, dict) and "choices" in result:
            if len(result["choices"]) > 0:
                if "message" in result["choices"][0] and "content" in result["choices"][0]["message"]:
                    response_text = result["choices"][0]["message"]["content"].strip()
                else:
                    raise HTTPException(status_code=500, detail="Unexpected response format: missing message.content")
            else:
                raise HTTPException(status_code=500, detail="No choices in response")
        elif isinstance(result, dict) and "error" in result:
            raise HTTPException(status_code=500, detail=f"Inference Providers API error: {result['error']}")
        else:
            raise HTTPException(status_code=500, detail=f"Unexpected API response format: {result}")
        
        # Clean up response
        response_text = response_text.strip()
        
        # Truncate at first complete sentence if very long
        if len(response_text) > 200:
            last_period = response_text.rfind(". ", 0, 200)
            if last_period > 50:
                response_text = response_text[:last_period + 1]
        
        return PromptResponse(response=response_text, model_loaded=True)
    except requests.Timeout:
        raise HTTPException(status_code=504, detail="Inference API timeout - model may be loading")
    except HTTPException:
        raise
    except Exception as e:
        error_msg = f"Generation error: {str(e)}"
        print(f"ERROR: {error_msg}", file=sys.stderr)
        print(f"ERROR: {error_msg}")  # Also print to stdout
        import traceback
        traceback.print_exc(file=sys.stderr)
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")

