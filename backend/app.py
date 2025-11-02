"""
FastAPI Backend for Hugging Face Spaces
This handles text generation requests from your Godot game.

To deploy:
1. Create a new Hugging Face Space
2. Select "FastAPI" as the SDK
3. Upload this file as app.py
4. Create requirements.txt with dependencies
5. Set the environment up for GPU if possible
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import time

app = FastAPI(title="Godot AI Game Backend")

# Enable CORS for web requests from your Godot game
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this to your itch.io domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Model will be loaded here (placeholder for now)
# You'll implement this after setting up the Space
model = None
pipe = None

class PromptRequest(BaseModel):
    prompt: str
    max_length: Optional[int] = 100

class PromptResponse(BaseModel):
    response: str
    model_loaded: bool = False

@app.get("/")
async def root(msg: Optional[str] = None):
    """Health check endpoint and generation endpoint (GET with query parameter)"""
    # If no message parameter, return status
    if not msg:
        return {
            "status": "online",
            "model_loaded": model is not None,
            "message": "AI Game Backend is running"
        }
    
    # If message provided, generate response
    request = PromptRequest(prompt=msg)
    return await generate_text(request)

@app.post("/")
async def root_post(request: PromptRequest):
    """Handle POST requests at root - Docker Spaces routing fallback"""
    return await generate_text(request)

@app.post("/generate", response_model=PromptResponse)
async def generate_text(request: PromptRequest):
    """
    Main endpoint for text generation.
    Your Godot game will POST to this endpoint.
    """
    # Basic validation
    if not request.prompt or len(request.prompt.strip()) == 0:
        raise HTTPException(status_code=400, detail="Prompt cannot be empty")
    
    if len(request.prompt) > 500:
        raise HTTPException(status_code=400, detail="Prompt too long (max 500 characters)")
    
    # TODO: Replace this with actual model inference
    # For now, return a placeholder response
    if model is None:
        # This is where you'll load your model when you're ready
        # For testing, we'll return a simple response
        return PromptResponse(
            response="Hello! I'm your AI assistant. (Model not loaded yet - add your LLM code here)",
            model_loaded=False
        )
    
    try:
        # TODO: Add your actual model inference here
        # Example structure:
        # response = pipe(request.prompt, max_length=request.max_length)
        # generated_text = response[0]["generated_text"]
        
        generated_text = "Model response would go here"
        return PromptResponse(
            response=generated_text,
            model_loaded=True
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check for monitoring"""
    return {"status": "healthy", "model_ready": model is not None}

@app.get("/generate")
async def generate_get(prompt: str):
    """GET endpoint as workaround for Docker Spaces POST routing issues"""
    request = PromptRequest(prompt=prompt)
    return await generate_text(request)

