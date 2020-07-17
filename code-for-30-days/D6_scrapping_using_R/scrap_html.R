library('xml2')
library('rvest')


test_page <- xml2::read_html('test.html')

marker <- test_page %>%
  xml2::xml_find_all("//script") %>%
  html_text() %>%
  toString()


 markertId <- str_match_all(marker,'var marker_.*')