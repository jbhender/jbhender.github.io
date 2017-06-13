### Notes: In "Settings", goto "Code" and enable "Soft-wrap R Source Files" to wrap these comments on the screen to read the wider ones.

### 1) R Review
# Discussion: - R vs RStudio
#             - Layout of RStudio
#             - Using scripts

# Basic R functionality
3 + 2
x <- 3
x
x + 2

# All of these are equivalent (mostly) for assignment
x <- 3
x = 3
3 -> x
# But the first is best (The = is slightly different in ways that only come into play with advanced R programming, the last -> is just a bit tricky to read.)

y <- 2
z <- x + y
x
y
z

# Vectors are simply a collection of elements
c(x, y, z)
a <- c(x, y, z)
b <- 7:5
a + b
# Arithmetic is done element-wise by default

# Can also save strings
myname <- "Josh"
mylastname <- "Errickson"
paste(myname, mylastname)
# Not super useful in statistical analyses. Instead, we typically convert these to "factors" which are numeric values with associated labels:
f <- c("a", "a", "d")
f
f <- as.factor(f)
f
unclass(f)

# Functions take in arguments
mean(a)
?mean
mean(x = a)
# Notice that we use = inside functions calls. This is *NOT* an assignment, this is argument definition. Use "<-" for assignment, "=" for argument definition.

# Everything is an object
mymeanfunction <- mean
mean(a)
mymeanfunction(a)

# In general only one of each named object can exist.
a <- 1
a
a <- 2
a

# However, there can be a function object and a non-function object with the same name, and R uses the appropriate one in context
mean <- mean(1:4)
mean
mean(1:3)

a <- c(1,5,2,5,2,4,1,2,3,4,5)
mean(a)
mean(a, trim = .25)
# Trimmed mean - exclude the top 25% and lowest 25% before computing the mean. Useful to address outliers.

# Function arguments can either be given in order or named:
mean(a, .25)
mean(x = a, .25)
mean(trim = .25, x = a)
mean(.25, a)
# If they are not given in order, they must be named!
# General convention: First argument is unnamed; following arguments are named.

# Getting help on a function
help(mean)
?mean

# logical TRUE and FALSE as expected
isTRUE(1 == 1)
isTRUE(TRUE)
isTRUE(FALSE)
isTRUE(T) # NEVER USE THIS!
T <- "abc"
isTRUE(T)
TRUE <- "abc"

# data.frame's will be how most of your data is stored.
d <- data.frame(x = c(1, 4, 3),
                y = c("a", "g", "g"))
d
str(d)
# Note that the columns are named. Rows can also be named. If a column isn't named, it will be given default names (X1, X2, etc). If rows aren't named, they are numbered.

# Libraries (packages) can be installed with "install.package" and loaded with "library":
install.packages("lme4")
library("lme4")

### Loading packages for ggplot2 and dplyr
# Load packages
# install.packages("ggplot2")
# install.packages("tidyverse")
# dplyr is part of the "tidyverse", a collection of packages by Hadley Wickham. We load the whole collection because there are a few helper functions scattered in other packages.
library(ggplot2)
library(tidyverse)

### 2) dplyr
# dplyr is the "grammar of data manipulation". It simplifies (in theory) accessing and manipulating data.

# We'll use the `mtcars` data set.
data() # List all available built-in data. NOT YOUR DATA!
data(mtcars)
str(mtcars)
View(mtcars) # Only works in RStudio
?mtcars

# `filter` can be used to subset the rows of the data.
filter(mtcars, mpg < 20)
filter(mtcars, mpg < 20 & mpg > 15)
filter(mtcars, mpg < 20, mpg > 15) # separate conditions are treated as "and"
filter(mtcars, mpg < 15 | mpg > 30)
# & and | are logical operators

# Let's save the car names as a variable rather than row names
mtcars$car <- rownames(mtcars)

# "select" instead subsets columns.
select(mtcars, car, mpg, am)
select(mtcars, transmission = am) # To rename columns

# We can select multiple variables at once.
select(mtcars, mpg:drat) # Depends on order of variables
select(mtcars, starts_with("mp"))
select(mtcars, ends_with("p"))
select(mtcars, contains("d"))

# Let's reorder to move the name of the car to the beginning.
mtcars <- select(mtcars, car, everything())

# Rename performs the same renaming as select without dropping or re-ordering columns.
mtcars <- rename(mtcars, tranmission = am)

# `arrange` sorts the data
arrange(mtcars, qsec)
arrange(mtcars, cyl, qsec)
arrange(mtcars, cyl, desc(qsec)) # descending

# `mutate` to create new variables
mutate(mtcars, wtlbs = wt*1000)
mutate(mtcars, wtlbs = wt*1000,
               logwt = log(wtlbs))
# I can refer to the variable I just created!

# `transmute` works identical to mutate followed by select
transmute(mtcars, wtlbs = wt*1000)

## "Chaining" or "piping
# Rather than "nesting" functions, we can pipe them instead.
head(select(mtcars, mpg))
select(mtcars, mpg) %>% head()
# %>% can be entered by Ctl+Shift+m on Windows or Shift+Mac+m on mac
mtcars %>% select(mpg) %>% head()
# You can think of each function having an invisible first argument which takes the ouput from the previous function.

# These sets of commands are equivalent.
mtcars2 <- filter(mtcars, mpg > 30)
mtcars2 <- select(mtcars2, car, mpg, axleratio = drat , wt)
mtcars2 <- arrange(mtcars2, mpg)
mtcars2

arrange(select(filter(mtcars, mpg > 30), car, mpg, axleratio = drat, wt), mpg)

mtcars %>% filter(mpg > 30) %>% select(car, mpg, axleratio = drat, wt) %>% arrange(mpg)

mtcars %>%
  filter(mpg > 30) %>%
  select(car, mpg, axleratio = drat, wt) %>%
  arrange(mpg)


# We can perform operations which are based on the data
transmute(mtcars, meanmpg = mean(mpg))
# Here `mean(mpg)` takes the average of the entire column.
# We can instead take the average by number of gears (`gear`):
mtcars %>%
  group_by(gear) %>%
  transmute(mpgbygear = mean(mpg)) %>%
  ungroup()
# `ungroup` is not technically necessary, but it is "best practices".

# Note that the return of the above is a "tibble", which is a data.frame with a few special attributes that is used frequently in the tidyverse. For all intents and purposes, you can ignore that and treat it as a data.frame.


# `summarize` collapses the data
summarize(mtcars, mean(mpg), max(wt), sum(hp))
summarize(mtcars, meanmpg = mean(mpg), maxwt = max(wt), totalhorsepower = sum(hp))

# Even better with `group-by`!
mtcars %>%
  group_by(gear) %>%
  summarize(mean(mpg), max(wt), sum(hp)) %>%
  ungroup()

# Notice that we don't pass variable names as strings. E.g.:
select(mtcars, "mpg")
select(mtcars, mpg)

# What if we have a variable name with spaces?
d <- data.frame(1:3)
names(d) <- "a b"
d
select(d, a b)
select(d, "a b")
select(d, `a b`)

## 2a) Exercises!
# Use the data set "midwest"
data(midwest)
# 0. Use `str` and `View` to get familiar with the data.
# 1. Get the area, population and percent college educated for Washtenaw County (Ann Arbor is in Washtenaw County).

# 2. What county has the highest percent college educated? What county above 1,000,000 people has the lowest percent college educated?

# 3. Collapsing by state, obtain the total population per state and the total area. Compute the population density (population/area).


### 3) ggplot2
# ggplot2 is based on "Grammar of Graphics" by Leland Wilkinson
# R has built-in plotting capabilities, however:
# - Each function has it's own learning curve so learning one type of plot doesn't translate to another.
# - Adding any complications to the plot can be very complicated.
# - Overlaying multiple plots (especially of different types) is non-trivial

# ggplot as opposed to base R plotting, does not require a complete plot.
ggplot(data = mtcars)
ggplot(mtcars)
# To create a plot, we require 3 things. First, the data.

# Second, to define the axes (and other characteristics), we need an "aesthetic mapping". Sometimes called a "mapping", sometimes called an "aesthetic". These "map" variables to aspects of the plot.
ggplot(data = mtcars,
       mapping = aes(x = mpg))
ggplot(mtcars,
       aes(x = mpg))
# Note this creates our axes, but still doesn't draw any plot

# Finally, we need to add a "geom" to tell ggplot how to represent the data. Each is `geom_<type>` where <type> is something like "histogram" or "scatter" or "boxplot". See http://ggplot2.tidyverse.org/reference/#section-layer-geoms for a full list
plot <- ggplot(mtcars, aes(x = mpg))
plot2 <- plot + geom_histogram()
plot2

plot + geom_histogram()
# Easy to change!
plot + geom_density()

ggplot(mtcars, aes(x = mpg)) + geom_histogram()
# Similar to dplyr where functions "inherit" from the prior ones.

# Let's consider scatter plots which are more common plots:
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point()

# We can add a best fit line:
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_smooth()
# A "smoothed" fit.

ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_smooth(method = "lm")
# Not that `method` is NOT inside an aesthetic - it is not defined by a variable.

# Still not useful - would rather have the line plotted on top of the points.
# ggplot can handle this:
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  geom_smooth(method = "lm")

# You can add as many as you want:
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  geom_smooth(method = "lm") +
  geom_smooth(color = "red")

# Order matters
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_smooth(color = "red") +
  geom_smooth(method = "lm") +
  geom_point()

# Location of the aesthetic
# So far, we've been putting the aesthetic in the ggplot call:
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point()

# Instead we can put it in the geom_ call:
ggplot(mtcars) +
  geom_point(aes(x = wt, y = mpg))

# Mixing it up can work ...
ggplot(mtcars, aes(x = wt)) +
  geom_point(aes(y = mpg)) +
  geom_smooth(aes(y = mpg), method = "lm")

# ... but be careful
ggplot(mtcars, aes(x = wt)) +
  geom_point(aes(y = mpg)) +
  geom_smooth(method = "lm")

# Any aesthetics in `ggplot` are inherited. Any aesthetics defined in a geom overwrite those inside `ggplot` and are NOT inherited. This differs from dplyr - in dplyr each function inherits the output of the previous function. With ggplot, each geom ONLY inherits from `ggplot`.

# `color` was used before NOT as an aesthetic.
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  geom_smooth(color = "green")
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  geom_smooth(aes(color = "green"))
# Anything in the aesthetic should refer to a variable.

# Something more useful...
# First, let's turn "gear" into a factor
mtcars <- mutate(mtcars, gear = as.factor(gear))
str(mtcars)

# Here color is refering to a variable, so it in the aesthetic.
ggplot(mtcars, aes(x = wt, y = mpg, color = gear)) +
  geom_point() +
  geom_smooth( method = "lm", se = FALSE)

ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point(aes(color = gear)) +
  geom_smooth(method = "lm", se = FALSE)
# The point adds the color aesthetic, the smooth does *not* inherit it.

# Can also work with continuous variables
ggplot(mtcars, aes(x = wt, y = mpg, color = hp)) +
  geom_point()

# There are other options
ggplot(mtcars, aes(x = wt, y = mpg, color = hp, shape = gear)) +
  geom_point()

# A few other useful geoms:
ggplot(mtcars, aes(x = hp, y = carb)) +
  geom_point()
# Looks ok I guess...

ggplot(mtcars, aes(x = hp, y = carb)) +
  geom_jitter()
# By adding a small amount of noise, we can see that multiple cars have the same hp and carb.

ggplot(mtcars, aes(x = hp, y = carb)) +
  geom_count()

# Adding some lines
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  geom_hline(yintercept = 20, color = 'red') +
  geom_vline(xintercept = 3, color = 'blue') +
  geom_abline(slope = 2, intercept = 10, color = 'green')

# Boxplot is another useful plot, x is the grouping variable, y is the variable to plot.
ggplot(mtcars, aes(x = gear, y = mpg)) +
  geom_boxplot()

# Now that we've covered all that, let's talk about a quicker method.
qplot(mtcars$wt)
qplot(mtcars$wt, mtcars$mpg)
# Does its best to "guess" the correct plot
# You can add geoms just as above.
qplot(mtcars$wt, mtcars$mpg) + geom_smooth()
# Should only use this for quick exploration. When creating plots for scripting or producing reports, use the full ggplot.

## 3a) Exercises!
# Continue using midwest data
data(midwest) # Reloading it in case it was modified earlier.
# 1. Create a histogram of area, first using `qplot` then using `ggplot`.

# 2. Generate a new variable which is log(population). Create a scatter plot between area and log population.

# 3. Color the points by percollege. Notice any patterns?

# 4. Examine the relationship between percent college and percent below poverty (Does a higher percent college graduates predict lower poverty?). Look at the help for `geom_hex` and create that plot. Add some best fit lines to describe the relationship.

### 4) "Back Pocket" - Writing Functions
# We've been using functions a lot. We briefly discussed that functions are objects, e.g.
mymeanfunction <- mean
mean(1:5)
mymeanfunction(1:5)
# Let's talk about writing your own functions.

# It's best to start with an example. Here's a function which will report whether the mean and median of a vector are within some short distance of each other.

mean_med_differ <- function(v, tolerance = .1) {
 mean <- mean(v)
 median <- median(v)
 if (abs(mean - median) > tolerance) {
   return(TRUE)
 } else {
   return(FALSE)
 }
}

mean_med_differ(1:10)
mean_med_differ(c(1, 2, 5, 10))
mean_med_differ(c(1, 2, 5, 10), tolerance = 1)

# The first line defines the name of the function, as well as any arguments. Arguments can have default arguments. There is a special argument "..." which you sometimes see. It is used to pass arguments to sub-functions.

trimmean <- function(x, ...) {
  mean(x, trim = .1, ...)
}
mean(c(1:10, 100))
trimmean(c(1:10, 100))
mean(c(1:10, 100, NA))
trimmean(c(1:10, 100, NA))
trimmean(c(1:10, 100, NA), na.rm = TRUE)

# Notice that trimmean does not have a "return" statement. This is optional; if not given, the output of the final line of code is returned. In general, it is safer to just always return. (Also, you need return if you want to exit earlier - see the if/else above).

# The Two Rules of Functions
# 1) Any object you use inside the function should be passed as an argument.
# BAD:
a <- 3
f <- function(b) {
  return(a + b)
}
f(2)
# GOOD:
f <- function(a, b) {
  return(a + b)
}
a <- 3
f(a, 2)
# 2) Anything you want to export from a function should be returned.
# BAD:
f <- function() {
  a <- 1
  b <- 2
  return(b)
}
f()
# oops I wanted a too!
# GOOD:
f <- function() {
  a <- 1
  b <- 2
  return(list(a = a, b = b))
}
f()$a
f()$b

# Let's do a ggplot example. We had this before:
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  geom_smooth(method = "lm") +
  geom_smooth(color = "red")
# Let's make it a function to simplify.
# First, we'll need to slightly tweak the above:
ggplot(mtcars, aes_string(x = "wt", y = "mpg")) +
  geom_point() +
  geom_smooth(method = "lm") +
  geom_smooth(color = "red")
# The tidyverse is odd about quoting variable names. `aes()` vs `aes_string()`.

ggscatter_and_fit_lines <- function(data, x, y) {
  ggplot(data, aes_string(x = x, y = y)) +
    geom_point() +
    geom_smooth(method = "lm") +
    geom_smooth(color = "red")
}
ggscatter_and_fit_lines(mtcars, "wt", "mpg")
ggscatter_and_fit_lines(mtcars, "qsec", "disp")
ggscatter_and_fit_lines(mtcars, "hp", "drat")

### 5) Solutions

# Use the data set "midwest"
data(midwest)
# 0. Use `str` and `View` to get familiar with the data.
str(midwest)
View(midwest)
?midwest
# 1. Get the area, population and percent college educated for Washtenaw County (Ann Arbor is in Washtenaw County).
midwest %>%
  filter(county == "WASHTENAW") %>%
  select(county, area, poptotal, percollege)
# 2. What county has the highest percent college educated? What county above 1,000,000 people has the lowest percent college educated?
midwest %>%
  select(county, state, percollege) %>%
  arrange(desc(percollege)) %>%
  head()
midwest %>%
  filter(poptotal > 1000000) %>%
  select(county, state, percollege) %>%
  arrange(percollege) %>%
  head()
# 3. Collapsing by state, obtain the total population per state and the total area. Compute the population density (population/area).
midwest %>%
  group_by(state) %>%
  summarize(pop = sum(poptotal), area = sum(area)) %>%
  ungroup() %>%
  mutate(density = pop/area)

# Continue using midwest data
data(midwest) # Reloading it in case it was modified earlier.
# 1. Create a histogram of area, first using `qplot` then using `ggplot`.
qplot(midwest$area)
ggplot(midwest, aes(x = area)) + geom_histogram()
# 2. Generate a new variable which is log(population). Create a scatter plot between area and log population.
midwest <- midwest %>% mutate(logpop = log(poptotal))
ggplot(midwest, aes(x = area, y = logpop))
# 3. Color the points by percollege. Notice any patterns?
ggplot(midwest, aes(x = area, y = logpop)) + geom_point(aes(color = percollege))
# 4. Examine the relationship between percent college and percent below poverty (Does a higher percent college graduates predict lower poverty?). Look at the help for `geom_hex` and create that plot. Add some best fit lines to describe the relationship.
?geom_hex
ggplot(midwest, aes(x = percollege, y = percbelowpoverty)) + geom_hex() + geom_smooth(color = 'green') + geom_smooth(method = "lm", color = 'red')
