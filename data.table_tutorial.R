
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

# Installing data.table r package
install.packages("data.table")

# load the library in R
library(data.table)

# CUrrently, I am running on my Macos, therefore, OPENMP is not automatically 
# supported by OpenMP, you have to set up by your own

# Faster funtion to load data using fread()

data.dummy <- fread("https://github.com/arunsrinivasan/satrdays-workshop/raw/master/flights_2014.csv")
dim(data.dummy)
names(data.dummy)
