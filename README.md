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
Fedora:
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
```
