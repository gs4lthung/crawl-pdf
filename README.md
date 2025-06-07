# 🕸️ AWMF PDF Scraper (R + Chromote)

This R script is designed to **scrape and download all PDF documents** from the [AWMF Register](https://register.awmf.org/de/start), including those located on internal subpages. It uses a **headless browser** to properly load JavaScript-rendered content and **recursively explores** internal links to ensure no documents are missed.

---

## 📌 Features

- ✅ Loads JavaScript-rendered web pages (like modern SPAs)
- ✅ Recursively visits internal subpages
- ✅ Extracts all `.pdf` links
- ✅ Automatically downloads PDFs to a local folder
- ✅ Skips duplicate URLs to avoid loops

---

## 🧰 Requirements

Make sure you have the following R packages installed:

```r
install.packages(c("rvest", "stringr", "downloader", "chromote"))
