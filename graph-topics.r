library(data.table)
library(ggplot2)
library(e1071)
source("R/funcs.R")

##
if(length(commandArgs(TRUE))==2) {
  title <- sprintf("Topics in %s", commandArgs(TRUE)[1])
  outfile <- commandArgs(TRUE)[2]
} else {
  title <- "Topics"
  outfile <- "viz.png"
}

# Import Inferred doc topic distributions
data1 = fread("tmp/inferred-pageframe-topics.txt")

# Import text keys
keys = fread("tmp/topic_keys.txt")
setnames(keys, c("topic", "p", "keys"))
keys$topic <- as.factor(keys$topic)

NTOPICS = (length(data1)-4)/2 # Two meta variables at the start, two blank columns at the end 

nam <- c('page', 'source', 
         paste(c('topic', 'proportion'), rep(1:NTOPICS, each = 2), sep = ""))
data1 <- data1[,1:(NTOPICS*2+2), with=F]
data1 <- setNames(data1, nam)

data <- reshape(data1, varying=3:(NTOPICS*2+2), direction = 'long', sep="")
data$topic = as.factor(data$topic) # Make sure numbered topics are not interpreted continuously
# Calculate peakedness, for identifying the "catch-all" topics
data[page>=25,":="(median=median(proportion), best.page=page[which.max(topic)], kurtosis=kurtosis(proportion)), by=topic][,is.best.page:=(page==best.page), by=topic]
data.order <- unique(data[order(best.page)]$topic)
data$topic <- factor(data$topic, levels = data.order)
data[, keys:=topic]
keys[, title:=keys]
keys$keys <- sprintf("Topics pertaining to: '%s'", truncString(keys$keys, maxlen=100))
levels(data$keys) <- keys[as.numeric(data.order)][,keys]

## a = data.frame(phases=1:7, pages=c(20, 111, 150, 217, 313, 413, 495)) # For Tess of the D'Urbervilles
ggplot(data[page>=25], # Remove high-median topics
       aes(x=page, y=proportion, group=topic)) + 
  #geom_vline(data=a, aes(xintercept=pages))+ # For Tess ofthe D'Urbervilles
  geom_line(color="#D51E33")+
  facet_wrap(~keys, nrow=NTOPICS, scales='free')+
  theme_htrc() +
  ggtitle(title)

ggsave(outfile, width=9, height=NTOPICS, scale=1, dpi=100)
