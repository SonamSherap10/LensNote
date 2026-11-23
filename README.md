# LensNote 📸📝

**Turn photos of handwritten notes, whiteboards, and textbook pages into neat Markdown study guides, topic folders, interactive quizzes, and source-grounded RAG Q&A.**

LensNote is a full-stack AI study companion built with **React (TypeScript)** and **Node.js (TypeScript)**, powered by **Google Gemini** and **Supabase (`pgvector`)**.

---

## 🎯 Overview

Students take dozens of photos of lecture boards, handwritten notebooks, and textbook diagrams—and rarely organize them afterward. LensNote closes that loop by turning raw camera or gallery photos into structured, searchable digital notebooks that you can chat with, quiz yourself on, and export as clean PDFs.

### How It Works

```text
[Snap / Upload Note Photos] 
         │
         ▼
[Gemini Multimodal Vision] ──► Transcribes handwriting, math ($LaTeX$), & code into Markdown
         │
         ▼
[Auto-Topic & Embedding]   ──► Files note under a Topic + stores vectors in Supabase pgvector
         │
         ├──► [RAG Q&A Chat]    Ask questions grounded strictly in your saved notes
         ├──► [Quiz Generator]  Auto-generate MCQs with explanations from any topic
         └──► [PDF Export]      Download clean, print-ready study PDFs
