# Setup Guide - Step by Step

This guide will walk you through setting up your AI game from scratch.

## Part 1: Setting Up Godot (Do This First)

### Step 1: Open Your Project
1. Open Godot 4.5
2. Open your project (this folder)
3. You should see `main.tscn` in the FileSystem

### Step 2: Set Up the Scene
1. Open `main.tscn` (double-click it)
2. The scene should already have the UI set up
3. If not, the scene structure should be:
   - Main (Control node) - root
     - VBoxContainer
       - ChatDisplay (RichTextLabel)
       - LoadingLabel (Label)
       - HBoxContainer
         - InputField (LineEdit)
         - SendButton (Button)
     - AIClient (Node) - this runs the AI client script

### Step 3: Test Locally (Before Backend)
1. Run the game (F5 or click Play)
2. You should see a chat interface
3. Type a message and click Send
4. You'll get an error (expected - no backend yet!)
5. This confirms your Godot setup works

---

## Part 2: Setting Up Hugging Face Backend

### Step 1: Create Hugging Face Account
1. Go to https://huggingface.co
2. Sign up for a free account
3. Verify your email if needed

### Step 2: Create a Space
1. Go to https://huggingface.co/spaces
2. Click "Create new Space"
3. Fill in:
   - **Space name**: `yourname-godot-ai-game` (lowercase, no spaces)
   - **SDK**: Select **FastAPI**
   - **Hardware**: Start with **CPU Basic** (upgrade to GPU later if needed)
   - **Visibility**: Public
4. Click "Create Space"

### Step 3: Upload Your Backend Code
1. In your Space, click the "Files" tab
2. Upload these files from the `backend/` folder:
   - `app.py`
   - `requirements.txt`
3. Click "Commit" (Hugging Face will auto-deploy)

### Step 4: Wait for Deployment
1. Go to the "App" tab
2. Wait 2-3 minutes for initial setup
3. You should see "API docs" link appear
4. Click it to see your FastAPI documentation

### Step 5: Get Your API URL
1. Your Space URL will be: `https://your-username-your-space-name.hf.space`
2. Copy this URL

---

## Part 3: Connect Godot to Backend

### Step 1: Update API URL in Godot
1. Open `scripts/ai_client.gd`
2. Find this line:
   ```gdscript
   var api_url: String = "https://your-username-your-space-name.hf.space/generate"
   ```
3. Replace with your actual Hugging Face Space URL
4. Make sure it ends with `/generate`

### Step 2: Test the Connection
1. Run your Godot game
2. Type a message and click Send
3. You should see "AI is waking up..." message
4. Wait 30-90 seconds (first request only!)
5. You should get a response (even if it's just a placeholder)

---

## Part 4: Add Actual AI Model (Next Steps)

Once the basic connection works, you can add a real LLM:

### Option A: Small Model (Recommended for Free Tier)
1. Edit `backend/app.py`
2. Uncomment and add model loading code
3. Use a small quantized model like:
   - `google/gemma-2-2b-it`
   - `microsoft/Phi-3-mini-4k-instruct`
4. Update `requirements.txt` to include model dependencies

### Option B: Use Hugging Face Inference API (Alternative)
- Use their hosted inference API instead
- Easier but less impressive for portfolio
- Requires API key (still free tier)

---

## Troubleshooting

### "Connection failed" error
- Check your API URL in `ai_client.gd`
- Make sure your Space is deployed (check "App" tab)
- Try accessing the URL in a browser first

### "Server error" responses
- Check Hugging Face Space logs (Settings > Logs)
- Make sure requirements.txt is correct
- Check that your Space hardware tier supports your needs

### Godot export issues
- Make sure you're using web export template
- Test in browser locally before uploading to itch.io
- Check browser console for CORS errors

---

## Next Steps After Setup

1. ✅ Get basic text generation working
2. ✅ Test cold start handling (works!)
3. ✅ Add better UI styling
4. ⏭️ Add image generation (Phase 2)
5. ⏭️ Polish and deploy to itch.io

---

## Resources

- [Godot HTTPRequest Docs](https://docs.godotengine.org/en/stable/classes/class_httprequest.html)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Hugging Face Spaces Guide](https://huggingface.co/docs/hub/spaces)
- [Deploying Models on Spaces](https://huggingface.co/docs/hub/spaces-sdks-docker)

