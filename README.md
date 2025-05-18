# 🤖 BLEH (bleh bleh) — Bot for Learning Everything Haphazardly

Welcome to **BLEH** (bleh bleh), the chatbot you never knew you needed — and maybe still don’t.  
BLEH lives in your Notion, answers your questions (sometimes even accurately), and syncs chaos with knowledge like a caffeinated intern.

## 🧠 What is BLEH?

BLEH is a chatbot integrated with a Language Model API (like OpenAI’s ChatGPT) and a Notion-based knowledge management system.

It helps you:

- Ask questions directly from Web App
- Get somewhat reasonable answers
- (Optionally) write those answers back into Notion so you can forget them later
- Organize and manage your chat into a knowledge-base

## ✨ Features

- 💬 Chat via a custom web app

## 🚀 Getting Started

1. Clone this repo:
   ```bash
   git clone https://github.com/hhtnghia321/BLEH.git
   cd bleh
   ```

## Deploy Instruction

### Prequistion

- Docker
- gcloud cli
- enable GKE
- enable Google Cloud Build
- enable Google Artifact Register

1. Login to your gcloud project
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```
   Your YOUR_PROJECT_ID can be acquired from console.gcloud
   Check your gcloud login
   ```bash
   gcloud auth list
   ```
   Check your gcloud project list and current project
   ```bash
   gcloud projects list
   gcloud config list project
   ```
2. Config your Cluster in ymls file
   ```bash
   values.yml
   ```
3. Deploy the Application to GKE
   ```bash
   . k8s-init.sh
   ```
