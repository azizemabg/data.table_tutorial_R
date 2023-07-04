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
flight[, dep_sch := dep_time - dep_delay]
View(flight)
