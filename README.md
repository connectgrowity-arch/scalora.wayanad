# Scalora — Modern React + TypeScript + Tailwind CSS

This project is a modern, modular conversion of the Scalora digital agency website, built with **React 18**, **TypeScript**, **Tailwind CSS**, **Vite**, SEO Schema markup, and a built-in **WordPress-style CMS Studio**, fully configured for **GitHub** and **GitHub Pages** hosting.

---

## 🚀 Key Highlights

1. **Modern Frontend Architecture**:
   - **React 18** with functional components & custom hooks (`useCardGlow`, `useReducedMotion`).
   - **TypeScript** (`strict: true`) for services, process steps, forms, and 3D sphere physics.
   - **Tailwind CSS v3** configured with Scalora's brand palette (`#0B0A0F` dark background, `#5C6CFF` indigo accent) and brand typography (**Space Grotesk** display/headings + **Inter** body/labels).
   - **Vite 6** configured with relative `base: './'` for seamless GitHub Pages subpath deployment.

2. **SEO & Discoverability Ready**:
   - Full Open Graph & Twitter/X Cards, canonical URL, crawler directives, PWA `manifest.json`, `robots.txt`, `sitemap.xml`, and JSON-LD Schema (`Organization`, `WebSite`, `FAQPage`).

3. **Extracted Media Assets**:
   - `public/assets/showreel.mp4` (~976 KB)
   - `public/assets/logo.jpg` & `public/assets/logo-footer.jpg`

---

## 📁 GitHub Repository Structure

```text
saro/
├── .github/
│   └── workflows/
│       └── deploy.yml       <-- GitHub Actions auto-build & deploy to GitHub Pages
├── docs/                    <-- Static GitHub Pages fallback folder (zero-build deploy)
│   ├── index.html
│   ├── admin.html
│   ├── .nojekyll
│   ├── assets/
│   └── data/site-content.json
├── public/
│   ├── .nojekyll
│   ├── admin.html           <-- CMS Admin Studio (works locally & on GitHub Pages)
│   ├── manifest.json
│   ├── robots.txt
│   ├── sitemap.xml
│   ├── assets/
│   └── data/site-content.json
├── data/
│   └── site-content.json    <-- Local server CMS database
├── src/
│   ├── components/          <-- 13 modular TSX components
│   ├── hooks/
│   ├── types/
│   ├── utils/
│   ├── App.tsx
│   ├── index.css
│   ├── main.tsx
│   └── vite-env.d.ts
├── .gitignore
├── index.html
├── preview.html             <-- Standalone local preview
├── server.ps1               <-- Zero-dependency Windows HTTP + CMS API server
├── START-WEBSITE.bat        <-- One-click Windows launcher
├── LICENSE
├── package.json
├── tailwind.config.js
├── tsconfig.json
└── vite.config.ts
```

---

## 🌐 Deploying to GitHub & GitHub Pages (`connectgrowity-arch/scalora.wayanad`)

1. **Push or upload** this folder to `https://github.com/connectgrowity-arch/scalora.wayanad.git`:
   ```bash
   git init
   git add .
   git commit -m "Deploy Scalora website"
   git branch -M main
   git remote add origin https://github.com/connectgrowity-arch/scalora.wayanad.git
   git push -u origin main
   ```
2. Open your repository on GitHub and go to **Settings → Pages**.
3. Choose **either** deployment option:
   - **Option A — GitHub Actions (Recommended)**:
     Under **Build and deployment → Source**, select **GitHub Actions**. GitHub will automatically run `.github/workflows/deploy.yml`, compile the TypeScript + React + Tailwind source (`npm install && npm run build`), and publish your site live!
   - **Option B — Static Branch Hosting (`/docs`)**:
     Under **Build and deployment → Source**, select **Deploy from a branch**, pick `main` and folder **`/docs`**, and click **Save**. Your site and CMS go live immediately at `https://connectgrowity-arch.github.io/scalora.wayanad/`.

---

## 🛠️ WordPress-Style CMS Admin Studio

- **Local Server**: Open `http://localhost:3000/admin` (or `/wp-admin`) to edit content and save directly to `data/site-content.json`.
- **GitHub Pages (Static)**: Open `https://connectgrowity-arch.github.io/scalora.wayanad/admin.html` to edit sections in browser storage and click **⬇ Export JSON** to download `site-content.json` for committing to GitHub.

---

## 💻 Running Locally

### Option 1: One-Click Windows Server (Zero Node Required)
Double-click **`START-WEBSITE.bat`** to start `server.ps1` and open `http://localhost:3000`.

### Option 2: Vite Dev Server (With Node.js)
```bash
npm install
npm run dev
npm run build
```
