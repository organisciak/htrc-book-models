# Custom Theme, starting from the ggthemes economist theme
require(ggthemes)
theme_htrc <- function(base_size = 10, base_family="sans",
                            horizontal=TRUE, dkpanel=FALSE, stata=FALSE) {
  base_theme <- theme_economist(base_size, base_family, horizontal, dkpanel, stata)
  ret <- base_theme + 
    theme(legend.position="none",
          axis.text.y = element_blank(),
          axis.title.y=element_blank(),
          axis.line.y=element_blank(),
          axis.ticks.y=element_blank(),
          panel.grid.major=element_blank(),
          plot.background = element_rect(fill = rgb(240, 240, 240, max = 255)),
          panel.background = element_rect(fill = rgb(240, 240, 240, max = 255)),
          strip.background=element_blank(),
          strip.text = element_text(size=10),
          axis.line.x = element_blank(),
          axis.text.x = element_blank(), 
          axis.ticks.x = element_line(size=0.5)
    )
  ret
}

# TruncString, via prettyR
truncString <- function (x, maxlen = 20, justify = "left") 
{
  ncharx <- nchar(x)
  toolong <- ncharx > maxlen
  maxwidth <- ifelse(toolong, maxlen - 3, maxlen)
  chopx <- substr(x, 1, maxwidth)
  lenx <- length(x)
  for (i in 1:length(x)) if (toolong[i]) 
    chopx[i] <- paste(chopx[i], "...", sep = "")
  return(formatC(chopx, width = maxlen, flag = ifelse(justify == 
                                                        "left", "-", " ")))
}