
#1) Part 2- Will mostly aim at analyzing things such as what is the most preferred tool for 
#implementing Datascience, Most used ML method, learning platform,What language they recommend etc
#and other more specific answers related to datascience and machine learning given by the survey 
#participants.

require(data.table)
require(highcharter)
require(ggplot2)
require(tidyverse)
setwd("C:/Users/Architect_shwet/Desktop/data science projects/kaggle data science survey")
Surveydf<-read.csv("multipleChoiceResponses.csv") #for faster data reading

attach(Surveydf)

table(MLToolNextYearSelect)
tooldf<-as.data.frame(table(MLToolNextYearSelect)) %>% arrange(desc(Freq))
#let's remove missing value
tooldf[1,]<-NA
tooldf<-na.omit(tooldf)
names(tooldf)<-c("Tool","Count")
#now let's plot the data
hchart(tooldf,hcaes(x=Tool,y=Count),type="column",name="Count",color="#9B6ED8") %>%  
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of tools used by participants",align="center") %>%
  hc_add_theme(hc_theme_elementary()) 

toptooldf<-na.omit(tooldf) %>% arrange(desc(Count)) %>% top_n(10)
#plotting a funnel chart of top 10 most used tools entered by the users
col <- c("#d35400", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d","#000004", "#3B0F70", "#8C2981", "#DE4968")

hchart(toptooldf,hcaes(x=Tool,y=Count),type="funnel",name="Count",color=col) %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Funnel chart of top 10 most used tools used by survey participants",align="center")

#Let's check Top countries uses which tools ?

#Let's first make a dataframe which consists of Top 10 particapnt's countries and grouped 
#by the preferred tool entered by them which is then summarized by the total count.

#dataframe of top 10 countries 
countryCount<-as.data.frame(table(Surveydf$Country)) %>%  top_n(10)

countryTool<-Surveydf %>% group_by(MLToolNextYearSelect,Country) %>%
  select(Country,MLToolNextYearSelect) %>% 
  filter(Country %in% countryCount$Var1, MLToolNextYearSelect %in% toptooldf$Tool) %>%
  summarise(total_count=n()) %>%
  arrange(desc(total_count))

hchart(countryTool,hcaes(x=Country,y=total_count,group=MLToolNextYearSelect),type="column") %>% 
  hc_title(text="Barplot of Top 10 Country grouped by Tool",align="center") %>%
  hc_exporting(enabled=TRUE) 

ggplot(aes(x=Country,y=total_count),data=countryTool) +
  geom_col(fill="purple") +
  coord_flip() +
  facet_wrap(~MLToolNextYearSelect)

#We can notice that Every top 10 country uses Tensorflow, followed by python , 
#then R as their preferred tools for implementing machine learning and data science.

#Let's see which gender prefers which tool amongst the top 10 most used tools?

genderTool<-Surveydf %>% group_by(MLToolNextYearSelect,GenderSelect) %>%
  select(GenderSelect,MLToolNextYearSelect) %>% 
  filter(MLToolNextYearSelect %in% toptooldf$Tool,GenderSelect %in% c("Male","Female")) %>%
  summarise(total_count=n()) %>%
  arrange(desc(total_count))

hchart(genderTool,hcaes(x=MLToolNextYearSelect,y=total_count,group=GenderSelect),type="column") %>% 
  hc_title(text="Gender vs Most preferred tool",align="center") %>%
  hc_exporting(enabled=TRUE) 


#checking the ratio of male to female users for tools-
genderTooldf<-genderTool %>% spread(key = GenderSelect,value=total_count) %>%
                  mutate(Percent_male = round((Male/(Male+Female))*100,2),Percent_female = round((Female/(Male+Female))*100,2))
                  %>% arrange()

hchart(genderTooldf,hcaes(x=MLToolNextYearSelect,y=Percent_female),name="Percent",type="column",color="#ED2FAE") %>%   hc_title(text="Percent of female using tools out of 100",align="center") %>%
  hc_exporting(enabled=TRUE) 


hchart(genderTooldf,hcaes(x=MLToolNextYearSelect,y=Percent_male),name="Percent",type="column",color="#F36A20") %>%   hc_title(text="Percent of Male using tools out of 100",align="center") %>%
  hc_exporting(enabled=TRUE) 

#Now let's see which ages group of people use which tool. I will only check the distribution 
#of the top used tools and the ages of participants.


AgeTooldf<-Surveydf %>% group_by(MLToolNextYearSelect) %>%
  filter(MLToolNextYearSelect %in% c("TensorFlow","R","Python","Spark / MLlib","Amazon Web services",
                                     "Hadoop/Hive/Pig","Google Cloud Compute","Jupyter notebooks")) %>% 
  select(MLToolNextYearSelect,Age)

hcboxplot(x = AgeTooldf$Age, var = AgeTooldf$MLToolNextYearSelect ,name = "Age", color = "#FF5733",outliers = FALSE) %>%
  hc_chart(type="column") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Boxplot of Top 3 Ml tools used by participants and their Ages",align="center") %>% 
  hc_add_theme(hc_theme_elementary())

#From the above plots R has highest median age of 31 , compared to other tools. Whereas 
#Hadoop and Python are used by relatively younger data scientists as inferred from this boxplot.

#Let's check the mean ages of the participants and the tools entered and used by them 
#and plot them. Let's summarize the data using dplyr package.

meanAgeTool<-Surveydf %>% group_by(MLToolNextYearSelect) %>%
  summarise(meanAge=mean(Age,na.rm=T)) %>%      
  arrange(desc(meanAge))

#rounding off the mean ages
meanAgeTool$meanAge<-round(meanAgeTool$meanAge,1)
names(meanAgeTool)<-c("Tool","MeanAge")#renaming the columns

topAgeTool<-meanAgeTool %>% filter(Tool %in% toptooldf$Tool)
col<-c("#d35400", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d","#000004", "#3B0F70", "#8C2981", "#DE4968")
#let's make a scatterplot

hchart(meanAgeTool,hcaes(x=Tool,y=MeanAge),name="Tool" ,type="scatter",color="#F44E1D") %>% 
  hc_chart(type="column") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Scatter plot of ML tools used by participants and their Mean  
           Ages",align="center") %>% 
  hc_add_theme(hc_theme_elementary())

hchart(topAgeTool,hcaes(x=Tool,y=MeanAge, size = MeanAge),color="#7CE3B0",name="Mean Age" ,type="bubble") %>% 
  hc_chart(type="column") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Bubble chart of top 10 ML tools used by participants and their Mean Ages",align="center") %>% 
  hc_add_theme(hc_theme_elementary())

#From the above plot of mean ages , we can see that R users have higher mean age than 
#Python,Tensorflow and Hadoop users.This means Python and Hadoop is more famous and used 
#amongst relatively younger data scientists.

#Let's analyze the most used ML method?

table(MLMethodNextYearSelect)

Mlmethod<-as.data.frame(table(MLMethodNextYearSelect)) %>% arrange(desc(Freq))

Mlmethod[1,]<-NA
names(Mlmethod)<-c("Method","Count")

hchart(na.omit(Mlmethod),hcaes(x=Method,y=Count),type="column",name="Count",color="#FF5733") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of ML Method used by participants",align="center") %>%
  hc_add_theme(hc_theme_elementary()) 


#treemap of most preferred methods of ML
hchart(Mlmethod, "treemap", hcaes(x = Method, value = Count,color=Count)) %>%
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Treemap of ML Method used by participants",align="center") 

#As we can notice the most used ML technique is Deep learning and neural networks followed by 
#time series analysis.

#Let's check the countrywise usage of ML methods.Again I am going to do it for top 10 countries.

countryMethod<-Surveydf %>% select(Country,MLMethodNextYearSelect) %>%
  group_by(Country,MLMethodNextYearSelect) %>%
  filter(Country %in% countryCount$Var1) %>%
  summarize(total_count=n())%>%
  arrange(desc(total_count))

#Let's first filter for United States and check the most used tools.

#First for United states
USmethoddf<-countryMethod %>% filter(Country=="United States") %>% arrange(desc(total_count))

USmethoddf[1,]<-NA

hchart(na.omit(USmethoddf),hcaes(x=MLMethodNextYearSelect,y=total_count),type="column",color="#BFD13D") %>%
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of ML Method used by participants in United States",align="center") %>%
  hc_add_theme(hc_theme_elementary()) 

#For India.

Indiamethoddf<-countryMethod %>% filter(Country=="India") %>% arrange(desc(total_count))

Indiamethoddf[1,]<-NA

hchart(na.omit(Indiamethoddf),hcaes(x=MLMethodNextYearSelect,y=total_count),type="column",color="red") %>%
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of ML Method used by participants in India",align="center") %>%
  hc_add_theme(hc_theme_elementary()) 

#For China.

ChinaMethoddf<-countryMethod %>% filter(Country=="People 's Republic of China") %>% arrange(desc(total_count))

ChinaMethoddf[2,]<-NA

hchart(na.omit(ChinaMethoddf),hcaes(x=MLMethodNextYearSelect,y=total_count,color=MLMethodNextYearSelect),type="column") %>%
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of ML Method used by participants in China",align="center") %>%
  hc_add_theme(hc_theme_elementary()) 

# USA,India and China combined.

MethodTopCountry<-countryMethod %>% filter(Country %in% c("United States","India","United Kingdom"))

MethodTopCountry[c(1,2,7),]<-NA


hchart(na.omit(MethodTopCountry),hcaes(x=MLMethodNextYearSelect,y=total_count,group=Country),type="column",color=c("#FFA500","#C71585","#00FF00")) %>%
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of ML Method used by top 3 participants Countries",align="center") %>%
  hc_add_theme(hc_theme_elementary()) 

# Let's check which is the most recommended tool by participants

table(LanguageRecommendationSelect)

toolRecomdf<-as.data.frame(table(LanguageRecommendationSelect)) 
names(toolRecomdf)<-c("tool","count")
toolRecomdf[1,]<-0 
toolRecomdf <- toolRecomdf %>% arrange(desc(count))


hchart(na.omit(toolRecomdf),hcaes(x=tool,y=count),color="#56C1FE",type="column") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of Recommended tools of participants",align="center") %>%
  hc_add_theme(hc_theme_elementary()) 

hchart(na.omit(toolRecomdf),hcaes(x=tool,y=count),color="#56C1FE",type="funnel") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of Recommended tools of participants",align="center") %>%
  hc_add_theme(hc_theme_elementary()) 

hcboxplot(x = Surveydf$Age , var = Surveydf$LanguageRecommendationSelect,name = "Age", 
          color = "#E127AB",outliers = FALSE) %>%
  hc_chart(type="column") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Boxplot of tools recommended by participants and their Ages",align="center") %>% 
  hc_add_theme(hc_theme_elementary())

#So from the above plot we can infer that most participants recommend python, R and Sql the most.

#Let's check from where participants collect data?

publicData<-as.data.frame(table(PublicDatasetsSelect)) %>% arrange(desc(Freq)) %>% top_n(20)
publicData[1,]<-NA
names(publicData)<-c("source",'count')

hchart(na.omit(publicData),hcaes(x=source,y=count),type="column",color="#26BA0B")

#So we discover that mostly people prefer online platforms such as Kaggle, data.worlds etc to 
#download public data sets, followed by google search and scraping data from web and github as 
#data sources to do data science and analytics projects.

#Let's check which is the favourite Platform to learn Data science?

#Let's check for the top 10 learning platforms
platformdf<- Surveydf %>% group_by(LearningPlatformSelect) %>%
  summarise(count=n()) %>% top_n(20) %>% arrange(desc(count))
platformdf[1,]<-NA

hchart(na.omit(platformdf),hcaes(x=LearningPlatformSelect,y=count, color = 'LearningPlatformSelect'),
       type="column",color="yellow") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Barplot of top 20 platforms used by participants to learn Data science",align="center") %>% 
  hc_add_theme(hc_theme_elementary())

#As expected most people prefer Kaggle, Online MOOC courses to learn data science related topics and 
#subjects.

#Now let's check and do some bi-variate analysis of Learning platform with other major variables.

#a) First let's check which age group prefers which platform. Let's do some data aggregation 
#and summarization to find mean of ages grouped by the learning platform

ageplatform <-Surveydf %>% filter(LearningPlatformSelect %in% platformdf$LearningPlatformSelect) %>% 
  group_by(LearningPlatformSelect) %>% 
  select(Age,LearningPlatformSelect)

ageplatform<-na.omit(ageplatform)

#let's first make a boxplot

hcboxplot(x = ageplatform$Age , var = ageplatform$LearningPlatformSelect,name = "Age", color = "cayn",outliers = FALSE) %>%
  hc_chart(type="column") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Boxplot of learning platform used by participants and their Ages",align="center") %>% 
  hc_add_theme(hc_theme_elementary()) 

by(ageplatform$Age,ageplatform$LearningPlatformSelect,summary) #summary statistics of age grouped by learning platform

#From the above boxplot we can see that younger participants generally prefer arvix and 
#youtube videos more as the median ages for these platforms is least i.e age of 26.

#Let's summarize and calculate mean ages for more clear picture and understanding.


MeanAgePlatform<-ageplatform %>% group_by(LearningPlatformSelect) %>%
  summarise(mean_age=round(mean(Age),1)) %>% arrange(desc(mean_age))


hchart(MeanAgePlatform,hcaes(x=LearningPlatformSelect,y=mean_age),type="scatter",name="Mean Age",color="#596536") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Scatter plot of mean of ages and the learning platform",align="center") %>% 
  hc_add_theme(hc_theme_elementary()) 


#Pie charts of the usefullness of each of the learning platform entered by the survey participants

df<- Surveydf %>% select(LearningPlatformUsefulnessArxiv,LearningPlatformUsefulnessYouTube,LearningPlatformUsefulnessKaggle,LearningPlatformUsefulnessCollege,LearningPlatformUsefulnessCourses) 
df<-df[complete.cases(df),]



# Data
hchart(df$LearningPlatformUsefulnessArxiv, "pie") %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Pie chart of Question How usefull is Arxiv as learning platform",align="center") %>% 
  hc_add_theme(hc_theme_elementary())

hchart(df$LearningPlatformUsefulnessCourses, "pie")  %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Pie chart of Question How usefull are Online courses as learning platform",align="center") %>% 
  hc_add_theme(hc_theme_elementary()) 

hchart(df$LearningPlatformUsefulnessCollege, "pie")  %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Pie chart of Question How usefull us Collage as learning platform",align="center") %>% 
  hc_add_theme(hc_theme_elementary()) 

hchart(df$LearningPlatformUsefulnessKaggle, "pie")  %>% 
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Pie chart of Question How usefull is Kaggle as learning platform",align="center") %>% 
  hc_add_theme(hc_theme_elementary()) 

hchart(df$LearningPlatformUsefulnessYouTube, "pie") %>%  
  hc_exporting(enabled = TRUE) %>%
  hc_title(text="Pie chart of Question How usefull is Youtube as learning platform",align="center") %>% 
  hc_add_theme(hc_theme_elementary()) 


















