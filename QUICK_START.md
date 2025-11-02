# Quick Start - Get Your AI Backend Working

Follow these steps in order:

## Step 1: Create Hugging Face Account (5 minutes)
1. Go to https://huggingface.co
2. Click "Sign Up" (top right)
3. Create a free account (can use email or GitHub)
4. Verify your email if prompted

## Step 2: Create a Space (10 minutes)
1. After logging in, go to https://huggingface.co/spaces
2. Click the **"Create new Space"** button (top right)
3. Fill out the form:
   - **Owner**: Select your username (should be pre-selected)
   - **Space name**: `yourname-godot-ai-game` 
     - Use lowercase letters, numbers, and hyphens only
     - Example: `morgan-godot-ai-game`
   - **SDK**: Select **"Docker"** (this lets us run FastAPI)
     - Note: FastAPI is not a direct option, but Docker allows us to run it
   - **Hardware**: Choose **"CPU basic"** (we'll upgrade later if needed)
   - **Visibility**: Make sure it's set to **"Public"**
4. Click **"Create Space"**

## Step 3: Upload Your Backend Code (5 minutes)
1. In your new Space, you'll see the file browser
2. Click the **"Files"** tab (top of the page)
3. You need to upload **three files** from your `backend/` folder:
   - Click **"Add file"** → **"Upload file"**
   - Upload `backend/app.py` → name it `app.py`
   - Click **"Add file"** → **"Upload file"** again
   - Upload `backend/requirements.txt` → name it `requirements.txt`
   - Click **"Add file"** → **"Upload file"** again
   - Upload `backend/Dockerfile` → name it `Dockerfile` (no extension needed)
4. Click **"Commit changes"** (bottom of page)
   - Add a commit message like "Initial backend setup"
   - Click **"Commit changes to main"**

## Step 4: Wait for Deployment (2-5 minutes)
1. Go to the **"App"** tab (next to Files)
2. Hugging Face will automatically start building your Space
3. You'll see a loading spinner - wait for it to finish
4. Once done, you'll see:
   - An API docs link (Swagger UI)
   - A URL at the top like: `https://your-username-your-space-name.hf.space`

## Step 5: Test Your API (2 minutes)
1. Click the **"API docs"** link in your Space
2. You should see FastAPI documentation
3. Test the `/` endpoint:
   - Click on "GET /" → Click "Try it out" → Click "Execute"
   - You should get a response: `{"status": "online", ...}`
4. Test the `/generate` endpoint:
   - Click on "POST /generate"
   - Click "Try it out"
   - In the request body, paste:
     ```json
     {
       "prompt": "Hello, how are you?"
     }
     ```
   - Click "Execute"
   - You should get back: `{"response": "Hello! I'm your AI assistant...", "model_loaded": false}`

## Step 6: Connect Godot to Your API (2 minutes)
1. Open your project in Godot
2. Open the file: `scripts/ai_client.gd`
3. Find this line (around line 13):
   ```gdscript
   var api_url: String = "https://your-username-your-space-name.hf.space/generate"
   ```
4. Replace it with your actual Space URL (from Step 4):
   ```gdscript
   var api_url: String = "https://YOUR-USERNAME-YOUR-SPACE-NAME.hf.space/generate"
   ```
   - Make sure it ends with `/generate`
   - Example: `https://morgan-godot-ai-game.hf.space/generate`

## Step 7: Test It! (1 minute)
1. Run your Godot game (F5 or click Play)
2. Type a message in the chat
3. Click "Send"
4. You should see:
   - "AI is waking up... 😴" message
   - After a few seconds, a response like "Hello! I'm your AI assistant..."
   - **Note**: First request will take 30-90 seconds (cold start - this is normal!)

## ✅ You're Done!

If Step 7 works, your basic setup is complete! You're now communicating between Godot and Hugging Face.

---

## Next Steps (Optional - Add Real AI)

Once the basic connection works, you can add a real LLM model:

1. Edit `app.py` in your Hugging Face Space
2. Add model loading code (see SETUP_GUIDE.md for examples)
3. Update `requirements.txt` with model dependencies
4. Commit the changes
5. Wait for redeployment

---

## Troubleshooting

**"Connection failed" error:**
- Double-check your API URL in `ai_client.gd`
- Make sure your Space is deployed (check "App" tab)
- Try accessing the URL in a browser first

**"Server error (Code: 404)":**
- Make sure your URL ends with `/generate` (not just the base URL)
- Check that your Space is running (green status in "App" tab)

**Space won't deploy:**
- Check the "Logs" tab for error messages
- Make sure `app.py` and `requirements.txt` are in the root of your Space
- Check that FastAPI is in your requirements.txt

**Still stuck?**
- Check Hugging Face Space logs (Settings → Logs)
- Verify your Space is public and accessible
- Test the API directly in the Swagger UI (API docs)

