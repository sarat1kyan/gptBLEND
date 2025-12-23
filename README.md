                                                 
               _   _____ __    _____ _____ ____  
       ___ ___| |_| __  |  |  |   __|   | |    \ 
      | . | . |  _| __ -|  |__|   __| | | |  |  |
      |_  |  _|_| |_____|_____|_____|_|___|____/ 
      |___|_|                                    


# 🎨 gptBLEND v2.0  

<div align="center">

**AI-Powered Blender Script Generator**

Describe 3D models in plain English and let AI generate **Blender-ready Python scripts** automatically.

![gptBLEND](https://img.shields.io/badge/gptBLEND-AI%20Blender%20Assistant-blue)
![Version](https://img.shields.io/badge/version-2.0-green)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-purple)

</div>


## 📌 Overview

**gptBLEND** bridges natural language and Blender automation.  
Instead of writing Python scripts manually, you simply **describe your scene**, and AI generates safe, executable Blender code for you.

Perfect for:
- Rapid prototyping
- Learning Blender Python API
- Automating repetitive modeling tasks
- Experimenting with procedural scenes

---

## ✨ Features

- 🧠 **Natural Language Input** – Describe scenes in plain English
- 🤖 **Multiple AI Models** – GPT-4, GPT-3.5-turbo, and compatible models
- 🔒 **Safety First** – Code executes inside guarded try/except blocks
- 🧭 **Interactive Menu** – Simple CLI interface
- 📝 **Full Logging** – Every generation and execution is tracked
- 🌍 **Cross-Platform** – Windows, Linux, macOS
- ⚙️ **Configurable** – API model, output file, safety mode

---

## 📋 Prerequisites

### Required
- **Blender** 3.0+
- **curl**
- **jq**
- **OpenAI API key**  
  👉 https://platform.openai.com/api-keys

### Optional
- **Git**
- **Python** 3.8+ (for advanced customization)

---

## 🚀 Installation & Quick Start

### Windows
```bat
git clone https://github.com/sarat1kyan/gptBLEND.git
cd gptBLEND
gptBLEND.bat
````

### Linux / macOS

```bash
git clone https://github.com/sarat1kyan/gptBLEND.git
cd gptBLEND
chmod +x gptBLEND.sh
./gptBLEND.sh
```

---

## 🎮 Usage Flow

1. Launch **gptBLEND** from the terminal
2. Enter your OpenAI API key (stored locally)
3. Select **Generate new Blender script**
4. Describe your 3D scene
5. (Optional) Review generated Python code
6. Execute automatically in Blender or manually

---

## 🧪 Example Prompts

```text
Create a red cube at position (0, 0, 0) that rotates slowly
```

```text
Generate a low-poly landscape with mountains, trees, and a sunset sky
```

```text
Create a bouncing ball using Blender physics simulation
```

```text
Design a sci-fi spaceship with animated thrusters and blinking lights
```

---

## ⚙️ Configuration

gptBLEND automatically creates a config file:

* **Linux/macOS:** `gptblend_config.sh`
* **Windows:** Stored in the script directory

```bash
# API Configuration
OPENAI_API_KEY="your-api-key"
API_MODEL="gpt-4"
OUTPUT_SCRIPT="blend_generated.py"
SAFETY_MODE="enabled"
```

### Environment Variables (Optional)

```bash
export OPENAI_API_KEY="your-key"
export API_MODEL="gpt-4"
```

---

## 🔒 Safety & Security

* 🧱 **Sandboxed Execution** – Wrapped in error-handling blocks
* 👀 **Preview Mode** – Review code before running
* 📄 **Detailed Error Logs**
* 🔐 **Local API Key Storage** (no cloud sync)

---

## 🐛 Troubleshooting

### Blender not found

* Ensure Blender is installed and available in `PATH`
* Or define the full Blender executable path in config

### API errors

* Validate your API key
* Ensure network connectivity
* Check OpenAI API quota

### Permission denied

```bash
chmod +x gptBLEND.sh
```

### jq not installed

```bash
sudo apt install jq
```

or
[https://stedolan.github.io/jq/](https://stedolan.github.io/jq/)

---

## 📄 Logs

Real-time execution logs:

```bash
tail -f blender_script.log
```

---

## 📁 Project Structure

```text
gptBLEND/
├── gptBLEND.bat           # Windows launcher
├── gptBLEND.sh            # Linux/macOS launcher
├── README.md              # Documentation
├── blend_generated.py     # Auto-generated Blender script
├── blender_script.log     # Execution logs
└── api_config.txt         # Stored API configuration
```

---

## 🧠 Tips for Best Results

* ✅ Be specific with dimensions and coordinates
* 🔄 Break complex scenes into steps
* 🧩 Use Blender terminology (materials, modifiers, lighting)
* 🧪 Test simple objects first
* 👁 Always review generated code for large scenes

---

## ⚠️ Limitations

* Extremely complex scenes may require manual tweaks
* Long animations may be partially generated
* OpenAI API usage costs apply
* AI may misinterpret ambiguous prompts

---

## 🔮 Roadmap

* Blender Add-on version
* Image-to-3D generation
* Prompt batching
* Scene templates
* Local AI model support (LLaMA, etc.)

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push the branch
5. Open a Pull Request

---

## 📄 License

MIT License
See `LICENSE` for details.

---

## 🙏 Acknowledgments

* **OpenAI** – GPT API
* **Blender Foundation** – Blender
---

**⭐ Star this repo if you found it helpful!**
[![BuyMeACoffee](https://raw.githubusercontent.com/pachadotdev/buymeacoffee-badges/main/bmc-donate-yellow.svg)](https://www.buymeacoffee.com/saratikyan)
[![Report Bug](https://img.shields.io/badge/Report-Bug-red.svg)](https://github.com/sarat1kyan/pocket-cf/issues)

---

🎨 **Happy Blending!**
Need help? Open an issue or check the troubleshooting section.
