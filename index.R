library(rvest)
library(stringr)
library(downloader)
library(chromote)

# Define base and start URL
base_url <- "https://register.awmf.org"
start_url <- paste0(base_url, "/de/start")

# Check if a URL is internal (on the same site)
is_internal_link <- function(url) {
  !is.na(url) && (str_starts(url, base_url) || str_starts(url, "/"))
}

# Normalize URL to absolute
normalize_url <- function(link) {
  if (str_starts(link, "http://") || str_starts(link, "https://")) {
    return(link)
  } else if (str_starts(link, "/")) {
    return(paste0(base_url, link))
  } else {
    return(NA)
  }
}

# Track visited URLs to avoid loops
visited_links <- character()
found_pdfs <- character()

# Recursive function to crawl pages and extract PDF links
crawl_for_pdfs <- function(url) {
  url <- normalize_url(url)
  if (is.na(url) || url %in% visited_links) return()

  cat("Visiting:", url, "\n")
  visited_links <<- c(visited_links, url)

  page <- tryCatch({
    read_html_live(url)
  }, error = function(e) {
    cat("  Failed to read:", url, "\n")
    return(NULL)
  })

  if (is.null(page)) return()

  # Extract all <a> links
  links <- page %>%
    html_elements("a") %>%
    html_attr("href") %>%
    unique()

  links <- links[!is.na(links) & links != ""]

  # Separate PDFs and subpages
  pdfs <- links[str_detect(links, "\\.pdf$")]
  pdfs <- sapply(pdfs, normalize_url)
  pdfs <- pdfs[!is.na(pdfs)]
  found_pdfs <<- unique(c(found_pdfs, pdfs))

  # Follow other internal links
  internal_links <- links[!str_detect(links, "\\.pdf$") & sapply(links, is_internal_link)]
  internal_links <- sapply(internal_links, normalize_url)
  internal_links <- internal_links[!is.na(internal_links)]

  # Recursively crawl next level (depth-1)
  for (link in internal_links) {
    if (!(link %in% visited_links)) {
      crawl_for_pdfs(link)
    }
  }
}

# Start crawling
cat("Starting recursive PDF scan...\n")
crawl_for_pdfs(start_url)

# Remove duplicates
found_pdfs <- unique(found_pdfs)

# Download found PDFs
if (length(found_pdfs) == 0) {
  cat("No PDF files found.\n")
} else {
  cat("Found", length(found_pdfs), "PDFs. Starting download...\n")

  download_dir <- "downloaded_pdfs"
  if (!dir.exists(download_dir)) {
    dir.create(download_dir)
  }

  for (url in found_pdfs) {
    filename <- basename(url)
    destination_path <- file.path(download_dir, filename)

    cat("Downloading:", url, "\n")
    tryCatch({
      download(url, destination_path, mode = "wb")
      cat("  Downloaded:", filename, "\n")
    }, error = function(e) {
      cat("  Error downloading", filename, ":", e$message, "\n")
    })
  }

  cat("All downloads complete.\n")
}
