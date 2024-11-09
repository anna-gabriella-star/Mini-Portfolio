
# Project R script

# Librairies 

if (!require(dplyr)) install.packages("dplyr")
if (!require(tidyr)) install.packages("tidyr")
if (!require(ggplot2)) install.packages("ggplot2")

library(dplyr)
library(tidyr)
library(ggplot2)


# 1) Import all the datasets 
skills_df <- read.csv("C:/Users/linae/Downloads/postings.csv/job_skills.csv")
salaries_df <- read.csv("C:/Users/linae/Downloads/postings.csv/salaries.csv")
industries_df <- read.csv("C:/Users/linae/Downloads/postings.csv/company_industries.csv")
postings_df <- read.csv("C:/Users/linae/Downloads/postings.csv/postings.csv")


# 2) Check missing values in each dataset
check_missing_values <- function(df, df_name) {
  missing_values <- colSums(is.na(df))
  missing_summary <- data.frame(Column = names(missing_values), MissingCount = missing_values)
  print(paste("Missing values summary for", df_name))
  print(missing_summary)
  return(missing_summary)
}
skills_missing <- check_missing_values(skills_df, "skills_df") 
salaries_missing <- check_missing_values(salaries_df, "salaries_df") 
industries_missing <- check_missing_values(industries_df, "industries_df") 
postings_missing <- check_missing_values(postings_df, "postings_df") 

# 3) Remove missing values from the salaries dataset 

# Remove rows with missing values in max_salary or min_salary and drop the med_salary column 
salaries_df_clean <- salaries_df %>% 
  filter(!is.na(max_salary) & !is.na(min_salary)) %>% 
  select(-med_salary) 

head(salaries_df_clean)

#4) Remove The missing values from the postings dataset 
# Step 1: Remove columns with high missing values 
columns_to_remove <- c("normalized_salary", "zip_code", "fips", "closed_time", "remote_allowed", "applies", "med_salary","posting_domain", "sponsored","skills_desc", "formatted_experience_level","application_url") 

# Drop the specified columns
postings_df_clean <- postings_df %>% select(-all_of(columns_to_remove))

# Step 2: Remove any remaining rows with missing values 
postings_df_clean <- postings_df_clean %>% drop_na() 

# View the cleaned dataset 
head(postings_df_clean) 

#5) Merge the datasets 
merged_df <- postings_df_clean %>% 
  inner_join(skills_df, by = c("job_id")) %>% 
  inner_join(salaries_df_clean, by = c("job_id"))%>%
  inner_join(industries_df, by = c("company_id"), relationship = "many-to-many") 

# View the merged dataset 
head(merged_df) 
View(merged_df) 
colnames(merged_df) 

# Save the merged dataset to a CSV file 
write.csv(merged_df, "merged_output.csv", row.names = FALSE)

## Change the original column listed time, expiry, listed_time (format timestamp en date) 
## Conversion by division by 1000 to have seconds
merged_df$original_listed_time <- as.POSIXct(as.numeric(merged_df$original_listed_time) / 1000, origin = "1970-01-01", tz = "UTC") 
merged_df$expiry <- as.POSIXct(as.numeric(merged_df$expiry) / 1000, origin = "1970-01-01", tz = "UTC") 
merged_df$listed_time <- as.POSIXct(as.numeric(merged_df$listed_time) / 1000, origin = "1970-01-01", tz = "UTC") 

# 6) Top 10 locations by number of job offers 
top_locations <- merged_df %>% 
  filter(location != "United States") %>% # Exclude "United States" 
  count(location, sort = TRUE) %>% 
  top_n(10) 

# Plot 
ggplot(top_locations, aes(x = reorder(location, n), y = n))+
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + 
  labs(title= "Top 10 Locations by Number of Job Offers", x = "Location", y = "Number of Job Offers")

# 7) Top 10 industries with the best salaries 

colnames(merged_df) 

#Convert max_salary to annual if it's hourly

merged_df <- merged_df %>% 
  mutate(max_salary_annual = ifelse(pay_period.x == "HOURLY", max_salary.x * 2080, max_salary.x)) %>% 
  mutate(max_salary_annual = ifelse(pay_period.y == "HOURLY",max_salary.y * 2080, max_salary.y))


# Calculate the average max salary by industry
top_industries <- merged_df%>% 
  group_by(industry) %>% 
  summarise(avg_max_salary = mean(max_salary.x, na.rm = TRUE))%>% 
  arrange(desc(avg_max_salary))%>% 
  top_n(10, avg_max_salary) 

# Plot the top industries by average max salary

ggplot(top_industries,aes(x = reorder(industry, avg_max_salary), y = avg_max_salary)) +
  geom_col(fill = "steelblue")+
  coord_flip() +
  labs(title = "Top 10 Industries by Average Max Salary", x = "Industry", y = "Average Max Salary") +
  scale_y_continuous(labels = scales::comma_format())+
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

top_industries

# 8) Top skills to have 
top_skills <- merged_df%>%
  count(skill_abr, sort = TRUE)%>% 
  top_n(10) 

ggplot(top_skills, aes(x = reorder(skill_abr, n), y = n)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Top 10 Most Demanded Skills", x = "Skills", y = "Count")

# Average salary by skills 
avg_salary_by_skill <- merged_df %>%
  filter(!is.na(skill_abr), !is.na(max_salary.x)) %>% # Exclude missing values 
  group_by(skill_abr) %>% 
  summarise(avg_salary = mean(max_salary.x, na.rm = TRUE))%>%
  top_n(10, avg_salary) 

ggplot(avg_salary_by_skill, aes(x = reorder(skill_abr, avg_salary), y = avg_salary))+
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Top 10 Skills with the Highest Salaries", x = "Skill", y = "Average Salary")

# 9) Top 10 job titles by average max salary 
avg_salary_by_title <- merged_df%>%
  group_by(title) %>% 
  summarise(avg_salary = mean(max_salary_annual, na.rm = TRUE))%>%
  top_n(10, avg_salary) 

ggplot(avg_salary_by_title, aes(x = reorder(title, avg_salary), y = avg_salary)) +
  geom_col(fill = "darkgreen") +
  coord_flip() +
  labs(title = "Top 10 Job Titles by Average Salary", x = "Job Title", y = "Average Salary") + 
  scale_y_continuous(labels = scales::comma_format())

# 10) Distribution of job offers by work type 
work_type_distribution <- merged_df%>% 
  count(work_type) 

ggplot(work_type_distribution, aes(x = work_type, y = n, fill = work_type)) +
  geom_bar(stat = "identity") +
  labs(title = "Distribution of Job Offers by Work Type", x = "Work Type", y = "Number of Job Offers") +
  theme_minimal() 

# 11) Top 10 job titles by number of views 
top_views_by_title <- merged_df%>% 
  group_by(title) %>% 
  summarise(total_views = sum(views, na.rm = TRUE))%>%
  top_n(10, total_views)

ggplot(top_views_by_title, aes(x = reorder(title, total_views), y = total_views)) +
  geom_col(fill = "blue") +
  coord_flip() +
  labs(title = "Top 10 Job Titles by Views", x = "Job Title", y = "Total Views") 

# 12) Top 10 companies by number of job offers 
top_companies <- merged_df%>% 
  count(company_name, sort = TRUE) %>% 
  top_n(10) 

ggplot(top_companies, aes(x = reorder(company_name, n), y = n)) +
  geom_bar(stat = "identity", fill = "darkred") +
  coord_flip() +
  labs(title = "Top 10 Companies by Number of Job Offers", x = "Company", y = "Number of Job Offers") 

# 13)Distribution of job offers by application type 
application_type_distribution <- merged_df %>% 
  count(application_type) 

ggplot(application_type_distribution, aes(x = application_type, y = n, fill = application_type)) +
  geom_bar(stat = "identity") +
  labs(title = "Distribution of Job Offers by Application Type", x = "Application Type", y = "Number of Job Offers") +
  theme_minimal()





