# TUTORIAL ON HOW TO USE DATA.TABLE in R ######################################
################################################################################
################################################################################
#
#
#
#
#
################################################################################
################################################################################

getwd()

# Tutorial for using data.table for fast and efficienty memory in R
# As for your information, data.table r package is one of the fastest package
# for data manipulation. 
# I will write tutorial regarding how to use all of function from data.table in R
# Many data scientist said that R is not compatible for working with large datasets
# more than 10 GB. But with data.table, it can perform data manipulation better
# than any other packages
# Some of sources mentioned that data.table is faster than dplyr even with pandas,
# data.table is still on the top level

# data.table syntax is as follow
# DT[i, j, by]
# i = subset rows, this parameter refers to rows, it same as "where" in SQL
# j = subset columns, this parameter refers to columns or "Select" in SQL
# by = within group, this parameter refers to adding group, so that
# all calculations would be done within group same as group_by dpyr
# and equivailent with group by in SQL

# There are other arguments that also can be added to data.table syntax
# with, which
# allow.catersian
# roll, rollends
# .SD, .SDcols
# on, mult, nomatch

# Installing data.table r package ####
install.packages("data.table")

# load the library in R ####
library(data.table)

# CUrrently, I am running on my Macos, therefore, OPENMP is not automatically 
# supported by OpenMP, you have to set up by your own

# Faster funtion to load data using fread() ####
flight <- fread("data.dummy.csv", sep = ",")
dim(flight)
names(flight)
head(flight, 5)

# Selecting and keeping columns ####
flight.origin <- flight[, origin] # it returns vector not data.table
View(flight.origin)

flight.origin <- flight[, .(origin)] # it returns a data.table because of .()
flight[, c("origin")] # can also be written like this

# keeping column based on column position
flight.month <- flight[, 2, with = FALSE]
View(flight.2)

# Keeping multiple columns 
# We are going to select origin, year, month, and hour from the dataset

flight.oymh <- flight[, .(origin, year, month, hour)]
View(flight.oymh)
flight.oymh[ hour >= 1 & hour <= 6]

# Keeping multiple column based on column position 
flight[, c(1:3), with = FALSE]

# Dropping column # Including one or more variables ####

# Dropping one variable
flight.drop <- flight[, !1, with = FALSE] # single variable based on column position
flight[, !c("year"), with = FALSE] # based on column name as string

# Dropping more than one variable 
names(flight)
flight[, !c(1:3), with = FALSE] # dropping column position 1 until 3 its position
flight[, !c("year", "month", "day"), with = FALSE]

# keeping variable that contain particular words ####
# in this case we are going to keep variable with prefix "arr"
# we can use %like% operator to find the pattern

flight[, names(flight) %like% "arr", with = FALSE]
flight[, names(flight) %like% "dep", with = FALSE]

# rename variables using data.table
# setnames() function will be employed later then
setnames(flight, 
         old = c("dest"), # Just add more strings, we you want to rename more columns
         new = c("Destination"))
names(flight)

# Subsetting rows or filtering #
# filtering one condition
flight[origin == "JFK"]

# Two condition different variable
flight[origin == "JFK" & Destination == "SFO"]

# Three condition different variable
flight[origin == "JFK" & Destination == "SFO" & carrier == "AA"]

# subsetting multiple values
unique(flight$Destination)
flight[Destination %in% c("ORD", "AVP", "CHO", "MVY")]
flight[month %in% c(8, 9, 10)] 
flight[month %in% c(8:10)] # it's the same as above

# Apply logical operator: NOT
# Subsetting all flights whose origin is not equal to JFK and LGA
unique(flight$origin)

flight[!origin %in% c("JFK", "LGA")]

# subsetting all flight which happened not in the month 1 until 6
flight[!month %in% c(1:6)]

# Filter based on multiple variables
# subset all flights whose origin is LGA and carrier F9 and HA
unique(flight$carrier)
flight[origin == "LGA" & carrier == c("F9")]
flight[origin == "LGA" & carrier %in% c("F9", "HA", "DL")]

# Faster data manipulation with indexing ####
# data.table uses binary search algorithm that makes data manipulation runs faster

# Binary search algorith is an efficient algorithm for finding a value froms sorted
# list of values. It involves repeteadly splitting in half the portion of the list that contains
# values, until you found the value that you were searching for. 

# It is important to set Key function in our dataset that can tells the system
# that data is sorted by the key column. 

# as an example we are going ot use origin as the key in the datasets
# Indexing (set key)
setkey(flight, origin)

# Filtering when setkey is already assigned before (or already ON)
flight[c("JFK", "LGA")]

# Performance comparison between using setkey() and not using it
system.time(flight[origin %in% c("JFK", "LGA")])
system.time(flight[c("JFK", "LGA")])

# Indexing multiple column ####
# we can also set keys to multiple columns like we did below to column "origin
# and "Destination". 
setkey(flight, origin, Destination)

# Filtering while setting keys on multiple columns
flight[.("JFK", "MIA")] # first key column "origin" match "JFK"
                        # second key column "destination" matches "MIA"
# Based on code above, you do not need to specify which column variable for 
# subsetting the particular value, see an example with original code as above without setkey()
flight[origin == "JFK" & Destination == "MIA"] # it gave us the same result as line 158 with setkey()
# but using setkey() function will make it more faster and easier, and also shorted codes

# To identify the columns indexed by 
key(flight)

# return setkey() to normal, without assigning specific variables
setkey(flight, year, month, day)

# Sorting the data
# We can also sort the data using setorder() function
# By default, it will work as ascending orders
setorder(flight, month, arr_time)
View(flight)

# Sorting data on descending order
setorder(flight, -month)

# Sorting data based on multiple variables
# the data will be sorted first by 
setorder(flight, month, day, -carrier)

# Adding columns and calculations on rows ####
# we can do any operation on rows by adding := operator
# In this example we are substracting dep_delay variable from dep_time variable
# to compute scheduled departure time

# Adding or creating new single column based on calculating existing column
flight[, dep_sch := dep_time - dep_delay]
View(flight)

# Adding multiple columns 
flight[, c("dep_sch", "arr_sch") := 
         .(dep_time - dep_delay, arr_time - arr_delay)] # .() is same as list()
flight[, c("dep_sch", "arr_sch") := 
         list(dep_time - dep_delay, arr_time - arr_delay)] # same as above

# If then Else ####
# there are two different method
# method 1: flight[, flag:= 1*(min < 50)]
# method 2: flight[, flag:= ifelse(min < 50, 1, 0)]
flight[, delay_status :=
         ifelse(dep_delay > 60, "long delay", ifelse(dep_delay == 30, "medium delay", "short delay"))]
flight[delay_status == "long delay"][order(dep_delay)]
flight[delay_status == "short delay"][order(dep_delay)]

# Writing sub Queries like SQL
# format DT[][][]
flight[, dep_sch :=
         dep_time - dep_delay][, .(dep_time, dep_delay, dep_sch)]
# we are computing scheduled departure time and then selecting only
# relevant columns

# Summarize and aggregate columns ####
flight[, .(mean = mean(arr_delay, na.rm = TRUE), 
           min = min(arr_delay, na.rm = TRUE), 
           max = max(arr_delay, na.rm = TRUE))]

# summarize multiple columns
# to summarize multiple variables, we can simply write all the summary
# statistics function in bracket. see below:
flight[, .(mean(dep_time), mean(dep_delay))]

# If you want to calculate summary statistics for a larger list of variables, 
# you can use .SD and .SDcols operators. 
# The .SD operator implies "subset of data"
flight[, lapply(.SD, mean), .SDcols = c("arr_delay", "dep_delay")]

# Summarize all numeric columns 
flight[, lapply(.SD, mean)]

# summarize wih multiple statistics
flight[, sapply(.SD, function(x) c(mean = mean(x), median = median(x), 
                                   var = var(x), sd = sd(x), 
                                   range = range(x)))]

# using group by (within group calculation) ####
flight[, .(mean_arr_delay = mean(arr_delay, na.rm = TRUE)), 
       by = origin]

# grouped by two variables
flight[, .(mean_arr_delay = mean(arr_delay, na.rm = TRUE)), 
       by = .(origin, carrier)][order(-mean_arr_delay)]

# Use key column in a by operation 
# instead of by, you can use keyby = operator
flight[, .(mean_arr_delay = mean(arr_delay, na.rm = TRUE)), 
       keyby = origin]

# summarize multiple variables by group "origin"
flight[, .(mean_arr_delay = mean(arr_delay, na.rm = TRUE), 
           mean_dep_delay = mean(dep_delay, na.rm = TRUE)), 
       by = origin]
flight[, lapply(.SD, mean, na.rm = TRUE), 
       .SDcols = c("arr_delay", "dep_delay"), 
       by = origin] # same as above code

# Remove duplicates ####
# you can remove non-unique / duplicates cases with unique()
# For example, you want to eliminate duplicates based on variable carrier
setkey(flight, "carrier")
unique(flight)

# Remove duplicated based on all the variables
setkey(flight, NULL)
key(flight)
unique(flight)

# Extract values within group
# Select the first and second values from categorical variable carrier
flight[, .SD[1:2, 
             by = carrier]] 
flight[, .SD[1:2, 
             by = carrier]] == flight[1:2, ]

# Select last value from a group
flight[, .SD[.N], 
       by = carrier]

# Applyig frank function 
flight.rank <- flight[, rank:= frank(-distance, ties.method = "min"), 
                      by = carrier][sort(rank)]
unique(flight.rank$rank)
View(flight.rank)
?frank

# Cummulative sum by group ####
flight[, cum :=
         cumsum(distance), 
       by = carrier]

# Between and like operator
dt <- data.table(x = 6:10)
dt
dt[x %between% c(7,9)] # selecting real value in that variable

# %like% is mainly used to find all the values that matches a pattern
dt <- data.table(name = c("dep_time", "dep_delay", "dep_sch", "dep_total", 
                          "arr_sch", "flight", "destination"), id = c(1:7))
dt
dt[name %like% "dep"]

# merging and join ####
# merging in data.table is similar to base r function called merge()
# The diffence is by default takes common key variables as a primary key to merge
# two datasets. data.frame takes common variable names a primary key to merge a dataset

dt1 <- data.table(A = letters[rep(1:3, 2)], X = 1:6, 
                  key = "A")
dt1
dt2 <- data.table(A = letters[rep(2:4, 2)], Y = 6:1, 
                  key = "A")
dt2

# inner join
# It returns all the matching observations in both the datasets
merge(dt1, dt2, by = "A")

# Left join
# it returns all observations from the left dataset and the matched
# observations from the right dataset
merge(dt1, dt2, by = "A", all.x = TRUE)

# rigth join
merge(dt1, dt2, by = "A", all.y = TRUE)

# Full join
# It return all rows when there is a match in one of the datasets
merge(dt1, dt2, all = TRUE)

# Convert data.table to data.fram
# using setDF() function

setDF(mydata)
set.seed(111)
x <- data.frame(a = sample(3, 10, TRUE), 
                b = sample(letters[1:3], 10, TRUE))
x
class(x)
setDT(x, key = "A")
setDT(x, key = "a")

# Reshaping data using data.table
# for reshaping or transposing data, we can use dcast.data.table()
# and melt.data.table() function
# it is from reshape2 package

# Calculate the total number of rows by month and then sort on descending order
flight[, .N, by = month][order(-N)]
# .N ==> calculate the number of rows or records for particular column
# indicated by = function
# .N operator is used to find count

# Find top 3 months with high mean arrival delay
flight[, .(mean_arr_delay = mean(arr_delay, na.rm = TRUE)),
       by = month][order(-mean_arr_delay)][1:3]

# Find the origin of flights having average total delay is greater than 20 min
flight[, lapply(.SD, mean, na.rm = TRUE), 
       .SDcols = c("arr_delay", "dep_delay"), 
       by = origin][(arr_delay + dep_delay) > 20]

# Extract average of arrival and departure delays for carrier == "DL"
# by origin and destination variables
flight[carrier == "DL", 
       lapply(.SD, mean, na.rm = TRUE), #calculating for mean for columns
       by = .(origin, Destination), 
       .SDcols = c("arr_delay", "dep_delay")] #the columns where indicated by .SD, mean

# Pull first value of "air_time" by "origin" and then sum the returned values
# when it is greater than 300

flight[, .SD[1], .SDcols = "air_time", 
       by = origin][air_time > 300, sum(air_time)]
