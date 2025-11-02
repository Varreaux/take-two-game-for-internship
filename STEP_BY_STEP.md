# Step-by-Step: Upload Your Files to Hugging Face

You've created your Space! Now you need to upload your 3 files. Follow these exact steps:

## What You're Seeing Right Now

You're on a page that shows example instructions. **You can ignore all of that** - we're going to use the web interface instead of Git commands.

## Step 1: Find the "Files" Tab

1. Look at the **top of the page** in your Hugging Face Space
2. You should see tabs like: **"App"**, **"Files"**, **"Settings"**, etc.
3. Click on the **"Files"** tab

## Step 2: Upload Your First File (app.py)

1. Click the **"Add file"** button (usually at the top right)
2. From the dropdown menu, select **"Upload file"**
3. A file browser will open
4. Navigate to: `/Users/morganwaddington/Documents/Tandon/Classes/Game Design CS-GY 6553 /AI_Game/take-two/backend/`
5. Select **`app.py`**
6. Click **"Open"** or **"Upload"**
7. The file should appear in the file list

## Step 3: Upload Your Second File (requirements.txt)

1. Click **"Add file"** again
2. Select **"Upload file"** from the dropdown
3. In the file browser, go to the same `backend/` folder
4. Select **`requirements.txt`**
5. Click **"Open"** or **"Upload"**

## Step 4: Upload Your Third File (Dockerfile)

1. Click **"Add file"** one more time
2. Select **"Upload file"**
3. Go to the same `backend/` folder
4. Select **`Dockerfile`** (it might show as just "Dockerfile" with no extension)
5. Click **"Open"** or **"Upload"**

## Step 5: Commit Your Changes

After uploading all 3 files, you need to "commit" them (this saves them):

1. Look at the **bottom** of the page - you should see a box for entering a commit message
2. Type a message like: `"Initial setup - FastAPI backend"`
3. Click the **"Commit changes to main"** button (usually green, at the bottom)
4. Wait a few seconds - it will upload

## Step 6: Wait for Deployment

1. Click on the **"App"** tab (at the top)
2. You'll see a loading spinner
3. Wait 2-5 minutes for Hugging Face to build your Docker container
4. When it's done, you'll see:
   - A green status indicator
   - Your Space URL at the top (like: `https://your-username-your-space-name.hf.space`)
   - An "API docs" link you can click

## Step 7: Get Your URL

Once deployment is complete:

1. Look at the **top of the page** - you'll see your Space URL
2. It will look like: `https://yourusername-godot-ai-game.hf.space`
3. **Copy this entire URL** (you'll need it for the next step)

## Step 8: Connect Godot

1. Open your Godot project
2. Open the file: `scripts/ai_client.gd`
3. Find line 13 that says:
   ```gdscript
   var api_url: String = "https://your-username-your-space-name.hf.space/generate"
   ```
4. Replace it with your actual URL + `/generate`, for example:
   ```gdscript
   var api_url: String = "https://yourusername-godot-ai-game.hf.space/generate"
   ```
5. Save the file

## That's It!

Run your Godot game and test it. The first request will take 30-90 seconds (cold start), then you should get a response!

---

## Troubleshooting

**Can't find the "Files" tab?**
- Make sure you're logged into Hugging Face
- Refresh the page
- Check the URL - it should say `/spaces/yourusername/your-spacename`

**Files won't upload?**
- Make sure you're selecting files from the `backend/` folder
- File names should be exactly: `app.py`, `requirements.txt`, `Dockerfile` (no extra extensions)

**Deployment fails?**
- Check the "Logs" tab for error messages
- Make sure all 3 files are uploaded
- Make sure the commit message is filled in before clicking "Commit"

