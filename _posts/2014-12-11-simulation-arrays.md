---
layout: post
title: Spatial, age and sex structured population simulation in R with arrays
author: Andy South
published: true
status: publish
tags: R 
---
 
I was tasked with creating a spatial, age and sex structured simulation of tsetse flies in R.
 
One of the first things I wanted to sort out was the main data structures that I was going to use.
 
I eventually settled on using arrays.
 

```r
summary(cars)
```

```
##      speed           dist       
##  Min.   : 4.0   Min.   :  2.00  
##  1st Qu.:12.0   1st Qu.: 26.00  
##  Median :15.0   Median : 36.00  
##  Mean   :15.4   Mean   : 42.98  
##  3rd Qu.:19.0   3rd Qu.: 56.00  
##  Max.   :25.0   Max.   :120.00
```
 
 
 
![plot of chunk unnamed-chunk-2](/figures/unnamed-chunk-2-1.png) 
 
