```plaintext
 ▗▄▄▖▗▖  ▗▖▗▄▄▄   ▗▄▄▖ ▄▄▄  ▗▞▀▘▐▌   ▄ 
▐▌   ▐▛▚▞▜▌▐▌  █ ▐▌   █   █ ▝▚▄▖▐▌   ▄ 
▐▌   ▐▌  ▐▌▐▌  █ ▐▌▝▜▌▀▄▄▄▀     ▐▛▀▚▖█ 
▝▚▄▄▖▐▌  ▐▌▐▙▄▄▀ ▝▚▄▞▘          ▐▌ ▐▌█ 
                         
```

**CMDGochi** is a lightweight, interactive command-line virtual pet client built entirely with **Bash**. Manage your digital pets easily from your terminal — create, feed, play with, and monitor your pets' stats in real-time.

---

## 🐾 Overview 🐾

CMDGochi brings the nostalgic Tamagotchi experience to your command line interface. Designed for simplicity and fun, CMDGochi lets you interact with multiple virtual pets, track their hunger, happiness, energy, and more — all using intuitive CLI commands.

Whether you're a developer, sysadmin, or terminal enthusiast, CMDGochi offers a playful break from your day without leaving your console.

<div align="center">

![CMDGochi Screenshot](https://i.kek.sh/F6yjWUD0EXP.png)

</div>


### 👤 Your Profile & Access
- 🔑 **Get Your API Key:** Sign up and receive your unique API key to connect with your pets.
- 🌐 **Language support**: Ready for multilingual UI (currently Magyar, English, Deutsch, Français, Español, Italiano, Nederlands, Čeština, Polski).

### 🐕 Meet Your Pets
- 🐾 **Create New Pets:** Give your pets cute names (4–16 characters) and pick their type. You can choose between 8 animals (pet types: cat 🐱, dog 🐶, parrot 🦜, hamster 🐹, rabbit 🐰, mouse 🐭, raccoon 🦝, badger 🦡)
- 📋 **See All Your Pets:** Check on your furry friends’ real-time stats whenever you want.
- 🦝 **ASCII art**: Charming pet visuals right in your terminal.
- 🗑️ **Say Goodbye:** Delete a pet if it’s time to part ways.

### 📊 Pet Well beeing
- ⏳ **Live Pet Stats:** Hunger 🍗, happiness 😊, energy ⚡, and health ❤️ update dynamically as time passes.
- 🩹 **Watch Their Health:** If hunger maxes out, happiness and energy drop, or your pet gets sick 🤒 or needs a bath 🛁, their health declines.
- 🎂 **Growing Up:** Pets get older and level up every 4 days — unless they’re feeling really down (health 0), then their growth pauses 🧊.

### 🎮 Fun & Care Actions
- 🍎 **Feed Them:** Reduce hunger and boost happiness.
- 🧸 **Play Together:** Lift their mood but watch their energy; too tired means no playtime.
- 🛌 **Nap Time:** Recharge energy but be ready for a bit more hunger.
- ❤️‍🩹 **Heal Up:** Cure sickness and bring back health.
- 🛁 **Give a Bath:** Keep them clean and healthy. — skipping it hurts their health.
- 💊 **Give Medicine:** Treat sickness and improve wellbeing. Pets can randomly get sick, but you can nurse them back with medicine 🤧.

### 🏆 Pet Hall of Fame 🏆
- 🌟 **Top Pets:** See the top 10 oldest pets and get cool stats about levels, age, health, happiness, and types of all pets.

### 🖥️ **SERVER**
This API is crafted with Flask and SQLite to offer a fun, simple way to care for your virtual pets and watch them grow.
The API Server run on cmdgochi.mooo.com:5555 domain

---



## 📥 Installation

### 📋 Prerequisites

Make sure your system has the following installed:

- **Bash** (default on Linux/macOS; on Windows, use [Git Bash](https://gitforwindows.org/) or [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install))
- **curl** (for sending HTTP requests)
- A **terminal with Unicode support** (to properly render ASCII art and special characters)

  ### 📦 Dependencies
Ubuntu/Debian:
```bash
sudo apt-get install jq curl git
```
Arch Linux /SteamOS:
```bash
sudo pacman -S jq curl git
```
RedHat / CentOS:
```bash
sudo yum install jq jq curl git
```
Fedora:
```bash
sudo dnf install jq curl git
```
macOS (Homebrew):
```bash
brew install jq curl git
```

### 💾 Clone the repository

```bash
git clone https://github.com/Pucur/CMDGochi.git
cd CMDGochi
bash cmdgochi.sh
```
