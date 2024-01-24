library(rvest)
library(googlesheets4)
library(dplyr)
library(stringr)

# read in 2023 scores from xfl page
xfl_page <- rvest::read_html("https://www.livesport.com/football/usa/xfl/results/")
#html call for away scores
away_scores <- xfl_page %>% 
  html_elements(".event__score--home") %>% 
  html_text()
#remove blank values
away_scores <- away_scores[nzchar(away_scores)]
#4th score has both away and home scores, so split away score
away_score_4 <- substr(away_scores[4],1,6)

#html call for home scores
home_scores <- xfl_page %>% 
  html_nodes("p > strong~ strong") %>% 
  html_text()
#remove blank values
home_scores <- home_scores[nzchar(home_scores)]
#4th score in away html, so take score from there
home_score_4 <- substr(away_scores[4],7,stringr::str_length(away_scores[4]))

#fix 4th score for both sides
away_scores[4] <- away_score_4
home_scores <- append(home_scores, home_score_4, after = 3)

#pulling dates of games
dates <- xfl_page %>%
  html_nodes("sup strong") %>%
  html_text()

#create table
xfl_scores_2023 <- data.frame(
  home_team = as.character(),
  home_score = as.numeric(),
  away_team = as.character(),
  away_score = as.numeric(),
  date = as.character(),
  stringsAsFactors = FALSE
)
#set up columns
home_team <- as.character(stringr::str_split(home_scores, " ", simplify = TRUE)[,1])
home_score <- as.numeric(stringr::str_split(home_scores, " ", simplify = TRUE)[,2])
away_team <- as.character(stringr::str_split(away_scores, " ", simplify = TRUE)[,1])
away_score <- as.numeric(stringr::str_split(away_scores, " ", simplify = TRUE)[,2])
date <- dates[1:length(home_team)]
#load columns in table
xfl_scores_2023 <- xfl_scores_2023 %>% add_row(home_team = home_team,
                           home_score = home_score,
                           away_team = away_team,
                           away_score = away_score,
                           date = date)
#write table to googlesheets
googlesheets4::write_sheet(xfl_scores_2023,
                           ss = "https://docs.google.com/spreadsheets/d/1EL8yHlKKnByf74V3JqxxNlMvtpe1OaVQLPVN27YwuiE/edit#gid=2052095649",
                           sheet = "xfl_scores_2023")

# TODO: work on pulling prior year scores
# TODO: convert team names to full cities and team names