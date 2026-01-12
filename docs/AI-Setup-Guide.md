# AI Setup Guide for ContentCapture Pro

ContentCapture Pro supports three AI providers for summarizing, rewriting, and improving your captured content.

---

## 🤖 Choose Your Provider

| Provider | Cost | Privacy | Speed | Best For |
|----------|------|---------|-------|----------|
| **Ollama** | Free | 100% Local | Medium | Privacy-focused users |
| **OpenAI** | Paid | Cloud | Fast | Best quality results |
| **Anthropic** | Paid | Cloud | Fast | Long-form content |

---

## Option 1: Ollama (Free & Private)

Ollama runs AI models locally on your computer. Your data never leaves your machine.

### Requirements
- Windows 10/11
- 8GB+ RAM (16GB recommended)
- ~5GB disk space per model

### Installation

1. **Download Ollama**  
   → [https://ollama.com/download](https://ollama.com/download)

2. **Run the installer**  
   Follow the prompts - it's straightforward

3. **Open Command Prompt and pull a model:**
   ```
   ollama pull llama3.2
   ```
   This downloads the Llama 3.2 model (~2GB)

4. **Start Ollama** (if not already running):
   ```
   ollama serve
   ```

5. **Configure ContentCapture Pro:**
   - Press `Ctrl+Alt+S` to open Settings
   - Enable AI Integration
   - Select "Ollama" as provider
   - Model: `llama3.2` (or whichever you pulled)
   - URL: `http://localhost:11434` (default)

### Recommended Models

| Model | Size | Best For |
|-------|------|----------|
| `llama3.2` | 2GB | General use, fast |
| `llama3.2:70b` | 40GB | Highest quality |
| `mistral` | 4GB | Good balance |
| `phi3` | 2GB | Fast, lightweight |

Pull any model with: `ollama pull modelname`

---

## Option 2: OpenAI (GPT-4, GPT-3.5)

OpenAI offers the most capable models but requires an API key and costs money per use.

### Get Your API Key

1. Go to [https://platform.openai.com/signup](https://platform.openai.com/signup)
2. Create an account or sign in
3. Navigate to **API Keys**: [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
4. Click **"Create new secret key"**
5. Copy the key (starts with `sk-`)

> ⚠️ **Keep your API key secret!** Never share it or commit it to GitHub.

### Pricing (as of 2025)

| Model | Input | Output | Notes |
|-------|-------|--------|-------|
| `gpt-4o-mini` | $0.15/1M | $0.60/1M | Best value |
| `gpt-4o` | $2.50/1M | $10/1M | Most capable |
| `gpt-3.5-turbo` | $0.50/1M | $1.50/1M | Legacy |

For typical use (summaries, rewrites), expect pennies per day.

### Configure ContentCapture Pro

1. Press `Ctrl+Alt+S` → Settings
2. Enable AI Integration
3. Select "OpenAI" as provider
4. Paste your API key
5. Model: `gpt-4o-mini` (recommended)

---

## Option 3: Anthropic (Claude)

Anthropic's Claude excels at nuanced writing and long documents.

### Get Your API Key

1. Go to [https://console.anthropic.com/](https://console.anthropic.com/)
2. Create an account
3. Navigate to **API Keys**
4. Generate a new key
5. Copy the key (starts with `sk-ant-`)

### Pricing (as of 2025)

| Model | Input | Output |
|-------|-------|--------|
| `claude-3-haiku-20240307` | $0.25/1M | $1.25/1M |
| `claude-3-sonnet-20240229` | $3/1M | $15/1M |
| `claude-3-opus-20240229` | $15/1M | $75/1M |

### Configure ContentCapture Pro

1. Press `Ctrl+Alt+S` → Settings
2. Enable AI Integration
3. Select "Anthropic" as provider
4. Paste your API key
5. Model: `claude-3-haiku-20240307` (fast & cheap)

---

## 🎯 Using AI Features

Once configured, press `Ctrl+Alt+A` to open the AI Assist menu:

| Action | What it does |
|--------|--------------|
| **Summarize** | Creates a concise summary |
| **Generate Title** | Suggests a catchy title |
| **Rewrite** | Rewrites for clarity |
| **Improve** | Enhances grammar and flow |
| **Custom Prompt** | Your own instructions |

You can also use AI on selected text or on any capture from the browser.

---

## 🔒 Privacy Notes

| Provider | Your Data |
|----------|-----------|
| **Ollama** | Never leaves your computer |
| **OpenAI** | Sent to OpenAI servers (see their [privacy policy](https://openai.com/policies/privacy-policy)) |
| **Anthropic** | Sent to Anthropic servers (see their [privacy policy](https://www.anthropic.com/privacy)) |

If privacy is critical, use Ollama.

---

## 🐛 Troubleshooting

### Ollama: "Connection refused"
- Make sure Ollama is running: `ollama serve`
- Check the URL is `http://localhost:11434`

### OpenAI: "Invalid API key"
- Make sure you copied the full key
- Check your API key hasn't expired
- Verify billing is set up at [platform.openai.com/billing](https://platform.openai.com/account/billing)

### Anthropic: "Authentication failed"
- Verify your API key is correct
- Check account status at [console.anthropic.com](https://console.anthropic.com/)

### General: "AI not responding"
- Test your internet connection
- Try a different model
- Check the provider's status page

---

## 📚 Resources

- **Ollama**: [ollama.com](https://ollama.com) | [GitHub](https://github.com/ollama/ollama)
- **OpenAI**: [platform.openai.com/docs](https://platform.openai.com/docs)
- **Anthropic**: [docs.anthropic.com](https://docs.anthropic.com)

---

*Last updated: December 2025*
