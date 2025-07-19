```plaintext
 ▗▄▄▖▗▖  ▗▖▗▄▄▄   ▗▄▄▖ ▄▄▄  ▗▞▀▘▐▌   ▄ 
▐▌   ▐▛▚▞▜▌▐▌  █ ▐▌   █   █ ▝▚▄▖▐▌   ▄ 
▐▌   ▐▌  ▐▌▐▌  █ ▐▌▝▜▌▀▄▄▄▀     ▐▛▀▚▖█ 
▝▚▄▄▖▐▌  ▐▌▐▙▄▄▀ ▝▚▄▞▘          ▐▌ ▐▌█ 
                         
```

**CMDGochi** is a lightweight, interactive command-line virtual pet client built entirely with **Bash**. Manage your digital pets easily from your terminal — create, feed, play with, and monitor your pets' stats in real-time.

---

## 🚀 Overview

CMDGochi brings the nostalgic Tamagotchi experience to your command line interface. Designed for simplicity and fun, CMDGochi lets you interact with multiple virtual pets, track their hunger, happiness, energy, and more — all using intuitive CLI commands.

Whether you're a developer, sysadmin, or terminal enthusiast, CMDGochi offers a playful break from your day without leaving your console.
👤 User Management
🔑 API Key Registration: Users register and receive a unique API key to authenticate requests.

🐕 Pet Creation & Management
🐾 Create Pets: Users can create pets with customizable names (4–16 characters) and types (default: 🐱 cat).

📋 Retrieve Pets: Users can fetch a list of their pets with real-time updated stats.

🗑️ Delete Pets: Users can delete their pets.

📊 Pet Status & Stats
⏳ Dynamic Stats Update: Pet attributes such as 🍗 hunger, 😊 happiness, ⚡ energy, and ❤️ health automatically update based on elapsed time.

🩹 Health Impact: Health decreases if hunger is maxed out, happiness and energy drop to zero, or the pet is sick 🤒 or needs a bath 🛁.

🎂 Age and Leveling: Pets gain age (in days) and level up every 4 days, unless health drops to zero, which freezes age and level 🧊.

🤧 Sickness & Healing: Pets can randomly become sick. Users can medicate 💊 sick pets to improve their health.

🎮 Interactions & Actions
🍎 Feed: Reduces hunger and increases happiness.

🧸 Play: Increases happiness but decreases energy; requires minimum energy level.

🛌 Sleep: Restores energy but increases hunger.

❤️‍🩹 Heal: Cures sickness and improves health if the pet is sick.

🛁 Bath: Resets the bathing need and improves health indirectly.

💊 Medicate: Specific endpoint to treat sickness and restore health.

🚿 Pet Hygiene
🧼 Bathing Requirement: Pets need baths at least once per day; neglect reduces health.

🏆 Statistics & Rankings
🌟 Top Pets Endpoint: Returns top 10 oldest pets and aggregate statistics such as average level, age, health, happiness, and type distribution.
---

## 🎯 Features

- **Multi-pet management**: Create and switch between multiple pets.
- **Choose your favorite animal breeds**: You can choose between 8 animals (cat,dog,parrot,hamster,rabbit,mouse,raccoon,badger)
- **Real-time stats**: View age, hunger, happiness, energy, and health.
- **ASCII art**: Charming pet visuals right in your terminal.
- **Simple commands**: Easy-to-remember commands for feeding, playing, resting, and more.
- **API integration**: Communicates with a backend server via RESTful API calls.
- **Language support**: Ready for multilingual UI (currently English, Hungarian, German, France).
- **Configurable API key**: Securely store and use your API credentials.

---

## 📥 Installation

### Prerequisites

Make sure your system has the following installed:

- **Bash** (default on Linux/macOS; on Windows, use [Git Bash](https://gitforwindows.org/) or [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install))
- **curl** (for sending HTTP requests)
- A **terminal with Unicode support** (to properly render ASCII art and special characters)

  ### Dependencies
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

### Clone the repository

```bash
git clone https://github.com/Pucur/CMDGochi.git
cd CMDGochi
bash cmdgochi.sh
```
