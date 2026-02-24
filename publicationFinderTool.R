############################################################
# NEON Publication Finder
############################################################

# ==========================
# 0. Load Packages
# ==========================

library(httr)
library(jsonlite)
library(dplyr)
library(stringr)
library(purrr)
library(tidyr)
library(readr)
library(stringdist)

# ==========================
# 1. USER INPUTS
# ==========================

path <- '~/Downloads/'
researchers <- read_csv(paste0(path, "res.csv"))

openalex_base <- "https://api.openalex.org/works"
neon_query<-"National Ecological Observatory Network"
output_dir <- paste0(path, "outputs/")
dir.create(output_dir, showWarnings = FALSE)

# ==========================
# 2. FUNCTION: Query OpenAlex
# ==========================

query_openalex <- function(search_term, per_page = 200, max_pages = 100) {
  
  results_accumulator <- list()
  
  for (page in 1:max_pages) {
    
    url <- paste0(
      openalex_base,
      "?filter=fulltext.search:\"",
      URLencode(search_term),
      "\"",
      "&select=id,title,doi,publication_year,abstract_inverted_index,authorships",
      "&per-page=", per_page,
      "&page=", page
    )
    
    response <- GET(url)
    if (status_code(response) != 200) break
    
    data <- fromJSON(content(response, as = "text", encoding = "UTF-8"),
                     simplifyVector = FALSE)
    
    if (length(data$results) == 0) break
    
    for (work in data$results) {
      
      results_accumulator[[length(results_accumulator) + 1]] <- tibble(
        id = work$id %||% NA_character_,
        title = work$title %||% NA_character_,
        doi = work$doi %||% NA_character_,
        publication_year = work$publication_year %||% NA_integer_,
        abstract_inverted_index = list(work$abstract_inverted_index),
        authorships = list(work$authorships)
      )
    }
    
    Sys.sleep(0.2)
  }
  
  if (length(results_accumulator) == 0) return(tibble())
  
  bind_rows(results_accumulator)
}

# ==========================
# 3. Retrieve NEON Publications
# ==========================

neon_pubs_raw <- query_openalex(neon_query)

# ==========================
# 4. Author Extraction
# ==========================

neon_pubs_raw <- neon_pubs_raw %>%
  mutate(
    author_list = map(
      authorships,
      ~ {
        if (is.null(.x)) return(NA_character_)
        
        map_chr(.x, function(a) {
          a$author$display_name %||% NA_character_
        })
      }
    ),
    authors = map_chr(
      author_list,
      ~ if (all(is.na(.x))) NA_character_
      else paste(.x[!is.na(.x)], collapse = ", ")
    )
  )

# Long format for researcher matching
author_long <- neon_pubs_raw %>%
  select(id, author_list) %>%
  unnest(author_list) %>%
  rename(work_id = id,
         author_name = author_list)

# ==========================
# Fuzzy Researcher Matching
# ==========================

researcher_names <- tolower(researchers$name)

author_matches <- author_long %>%
  mutate(author_lower = tolower(author_name)) %>%
  rowwise() %>%
  mutate(
    min_distance = min(
      stringdist(author_lower,
                 researcher_names,
                 method = "jw")   
    ),
    matched_researcher =
      researchers$name[
        which.min(
          stringdist(author_lower,
                     researcher_names,
                     method = "jw")
        )
      ]
  ) %>%
  ungroup() %>%
  filter(min_distance < 0.1)   # fuzzy

write_csv(author_matches,
          file.path(output_dir,
                    "researcher_publication_matches.csv"))

# ==========================
# 5. Abstract Reconstruction
# ==========================

reconstruct_abstract <- function(inv_index) {
  
  if (is.null(inv_index) || length(inv_index) == 0)
    return(NA_character_)
  
  words <- names(inv_index)
  positions <- unlist(inv_index, use.names = FALSE)
  
  if (length(words) == 0 || length(positions) == 0)
    return(NA_character_)
  
  word_rep <- rep(words, lengths(inv_index))
  
  if (length(word_rep) != length(positions))
    return(NA_character_)
  
  df <- data.frame(
    word = word_rep,
    position = positions,
    stringsAsFactors = FALSE
  )
  
  df <- df[order(df$position), ]
  
  paste(df$word, collapse = " ")
}

# ==========================
# 6. Build Master Publication Table
# ==========================

neon_pubs <- neon_pubs_raw %>%
  mutate(
    abstract = map_chr(
      abstract_inverted_index,
      ~ safely(reconstruct_abstract)(.x)$result %||% NA_character_
    )
  ) %>%
  select(id, title, publication_year, doi,
         authors, abstract)

# ==========================
# 7. Biorepository Detection
# ==========================

biorepo_keywords <- c(
  "Biorepository",
  "repository",
  "collection",
  "sample",
  "specimen",
  "biorepo.neonscience.org",
  "Steger", "Husain",
  "Yule", "Betancourt",
  "Arizona State University"
)

biorepo_pattern <- paste(biorepo_keywords, collapse = "|")

neon_pubs <- neon_pubs %>%
  mutate(
    biorepository_related =
      str_detect(abstract,
                 regex(biorepo_pattern,
                       ignore_case = TRUE))
  )

# Write final publication sheet
write_csv(
  neon_pubs,
  file.path(output_dir,
            "neon_publications.csv")
)


############################################################
# END SCRIPT
############################################################