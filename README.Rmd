---
title: "R Notebook"
output:
  html_document:
    df_print: paged
---

Load Libraries
```{r}
library(plyr)
library(tidyverse)
library(lubridate)
library(here)
library(usethis)
```

Setting date format to English so that no one is bothered by German month names
```{r}
Sys.setlocale("LC_TIME", "C")
```

Importing data
```{r}
vacc<-read.csv("vaccinations.csv")
vacc
head(vacc)
##dates<-vacc$date
```

Extracting four different income classes from data and combining them
```{r}
low = filter(vacc,str_detect(iso_code,"OWID_LIC"))
lowmid = filter(vacc,str_detect(iso_code,"OWID_LMC"))
upmid = filter(vacc, str_detect(iso_code,"OWID_UMC"))
high = filter(vacc, str_detect(iso_code, "OWID_HIC"))
inc_classes=rbind(low,lowmid,upmid, high)
inc_classes
```

Changing "date" from <chr> to <date> and appending it to the dataframe
So that graph later recognises "date" as continous and not discrete
```{r}
str(inc_classes$date)
inc_classes$date
dates_form=ymd(inc_classes$date)
str(dates_form)
inc_classes <- inc_classes %>%
  add_column(DateForm =dates_form)
inc_classes
```
Reordering legend labels by introducing new factored column in dataframe
```{r}
inc_classes$inc_fac <- factor(inc_classes$location, levels=c("High income", "Upper middle income", "Lower middle income", "Low income"), 
                    labels=c("High income", "Upper middle income", "Lower middle income", "Low income"))
```

Plotting graph
```{r}
ggplot(data=inc_classes)+
  geom_line(mapping=aes(x=dates_form,y=people_vaccinated_per_hundred,group=inc_fac,color=inc_fac),size=1.5)+
  
  ## TITLE and LEGEND manipulation
  labs(title="Vaccination progress in different income classes")+
  scale_colour_discrete("Income Classes",)+

  ## X-AXIS manipulation
  theme(axis.text.x = element_text(color="black", size=10, angle=45),axis.text.y = element_text(color="black",size=9, angle=0))+
  scale_x_date(date_breaks = "months" , date_labels = "%b-%y")+
  xlab("Date")+

  ## Y-AXIS manipulation
  scale_y_continuous(name="vaccinated persons / 100 persons \n (% vaccinated)",breaks = scales::pretty_breaks(n = 10))
```
