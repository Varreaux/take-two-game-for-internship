# AI Game - Take Two

A 3D Godot game featuring AI-powered text and image generation, designed for portfolio demonstration.

## Architecture

- **Client**: Godot web game (hosted on itch.io)
- **Backend**: FastAPI microservice on Hugging Face Spaces (free tier)
- **Features**: 
  - Text generation using LLM
  - Image generation using Stable Diffusion (future)

## Development Plan

### Phase 1: Text Generation (START HERE)
1. Set up Hugging Face Space with FastAPI
2. Implement simple LLM endpoint
3. Build Godot client with HTTPRequest
4. Handle cold starts gracefully

### Phase 2: Image Generation
1. Add Stable Diffusion endpoint to FastAPI
2. Implement image display in Godot
3. Handle Base64 image decoding

### Phase 3: Polish & Integration
1. Combine text and image generation
2. Improve UI/UX
3. Add error handling and rate limiting

## Notes

- Free tier has ~15 min inactivity timeout (cold starts)
- Treat cold starts as a feature, not a bug
- Use smaller models to fit free GPU memory limits

