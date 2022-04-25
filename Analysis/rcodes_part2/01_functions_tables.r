##############################
## Function to add p values ##
##############################
rndr <- function(x, name, ...) {
  if (length(x) == 0) {
    y <- data[[name]]
    s <- rep("", length(render.default(x=y, name=name, ...)))
    if (is.numeric(y)) {
      # assuming unequal variances
      p <- t.test(y ~ data$Group, var.equal = FALSE)$p.value
    } else {
      # p <- chisq.test(table(y, droplevels(data$Group)))$p.value
      p <- fisher.test(table(y, droplevels(data$Group)))$p.value # use fishers exact test more conservative
    }
    s[2] <- sub("<", "&lt;", format.pval(p, digits=3, eps=0.001))
    s
  } else {
    render.default(x=x, name=name, ...)
  }
}

rndr.nonpara <- function(x, name, ...) {
  if (length(x) == 0) {
    y <- data[[name]]
    s <- rep("", length(render.default(x=y, name=name, ...)))
    if (is.numeric(y)) {
      # assuming unequal variances
      p <- wilcox.test(y ~ data$Group, var.equal = FALSE)$p.value
    } else {
      #p <- chisq.test(table(y, droplevels(data$Group)))$p.value
      p <- fisher.test(table(y, droplevels(data$Group)))$p.value # use fishers exact test more conservative
    }
    s[2] <- sub("<", "&lt;", format.pval(p, digits=3, eps=0.001))
    s
  } else {
    render.default(x=x, name=name, ...)
  }
}

rndr.lmm <- function(x, name, ...) {
  if (length(x) == 0) {
    y <- data[[name]]
    s <- rep("", length(render.default(x=y, name=name, ...)))
    if (is.numeric(y)) {
      
      model = lmerTest::lmer(y ~ Group_lmm + (1 |Cluster.no), data = data)
      nmodel = summary(model)
      p = nmodel$coefficients[2, 5]
      
    } else {
      ## should this be binomial family?
      # p <- chisq.test(table(y, droplevels(data$Group)))$p.value
      p <- fisher.test(table(y, droplevels(data$Group)))$p.value # use fishers exact test more conservative
      
    }
    s[2] <- sub("<", "&lt;", format.pval(p, digits=3, eps=0.001))
    s
  } else {
    render.default(x=x, name=name, ...)
  }
}

# model = glm(data$Intervention ~ data$Sex, family = 'binomial')
# summary(model)

rndr.strat <- function(label, n, ...) {
  ifelse(n==0, label, render.strat.default(label, n, ...))
}

my.render.cont <- function(x) {
  with(stats.apply.rounding(stats.default(x), digits=2), c("",
                                                           "Mean (SD)"=sprintf("%s (&plusmn; %s)", MEAN, SD)))
}

my.render.cont.JEM <- function(x) {
  c(with(stats.apply.rounding(stats.default(x), digits=3), c("", "Mean (SD)"=sprintf("%s (%s)", MEAN, SD))), 
    with(stats.apply.rounding(stats.default(x), digits=3), c("Median [Q1, Q3] "=sprintf("%s [%s, %s]", MEDIAN, Q1, Q3))), 
    with(stats.apply.rounding(stats.default(x), digits=3), c("Additional [min, max] "=sprintf("[%s, %s]", MIN, MAX))))
}

my.render.cat <- function(x) {
  c("", sapply(stats.default(x), function(y) with(y,
                                                  sprintf("%d (%0.0f %%)", FREQ, PCT))))
}