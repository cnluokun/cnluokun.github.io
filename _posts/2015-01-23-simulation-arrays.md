---
layout: post
title: Spatial, age and sex structured population simulation in R with arrays
author: Andy South
published: true
status: publish
draft: false
tags: R 
---
 
In this post I'll outline why and how I use arrays as the main data structure in a population simulation which represents the age, sex and spatial location of tsetse flies in the landscape. An earlier post outlines the background to this [tsetse population simulation]({% post_url 2014-12-12-rtsetse-intro %}).
 
 
I wanted a data structure that would make it easy and transparent for me to access elements with minimal code. I considered data frames, matrices and lists but opted for arrays. Hadley Wickham's excellent [Advanced R Data Structures](http://adv-r.had.co.nz/Data-structures.html) section was very helpful.
 
### Arrays
An `array` in R is a multi-dimensional object, and a `matrix` is a special case of an `array` with just 2 dimensions. The code below shows how you can use the `dim` argument to the `array` function to set the number and size of dimensions. In this example I just fill the array with sequential values from 1 to 24.
 
 

{% highlight r %}
array(c(1:24), dim=c(4,3,2))
{% endhighlight %}



{% highlight text %}
## , , 1
## 
##      [,1] [,2] [,3]
## [1,]    1    5    9
## [2,]    2    6   10
## [3,]    3    7   11
## [4,]    4    8   12
## 
## , , 2
## 
##      [,1] [,2] [,3]
## [1,]   13   17   21
## [2,]   14   18   22
## [3,]   15   19   23
## [4,]   16   20   24
{% endhighlight %}
 
### Naming array dimensions
To reduce the risk of bugs caused by accessing incorrect array elements you can name dimensions and use the names to access elements. You can use the `dimnames` argument to name both the elements within each dimension (e.g. F,M) and the dimension itself (e.g. sex). One way of doing this is to set `dimnames` to a named list. The code below shows how I create an array with spatial, sex and age dimensions.
 
 

{% highlight r %}
nY <- 4
nX <- 3
iMaxAge <- 2
sex <- c("F","M")
dimnames1 <- list( y=paste0('y',1:nY), x=paste0('x',1:nX), sex=sex, age=paste0('age',1:iMaxAge))
nElements <-  nY*nX*iMaxAge*length(sex)
aGrid <- array(1:nElements, dim=c(nY,nX,2,iMaxAge), dimnames=dimnames1)
aGrid
{% endhighlight %}



{% highlight text %}
## , , sex = F, age = age1
## 
##     x
## y    x1 x2 x3
##   y1  1  5  9
##   y2  2  6 10
##   y3  3  7 11
##   y4  4  8 12
## 
## , , sex = M, age = age1
## 
##     x
## y    x1 x2 x3
##   y1 13 17 21
##   y2 14 18 22
##   y3 15 19 23
##   y4 16 20 24
## 
## , , sex = F, age = age2
## 
##     x
## y    x1 x2 x3
##   y1 25 29 33
##   y2 26 30 34
##   y3 27 31 35
##   y4 28 32 36
## 
## , , sex = M, age = age2
## 
##     x
## y    x1 x2 x3
##   y1 37 41 45
##   y2 38 42 46
##   y3 39 43 47
##   y4 40 44 48
{% endhighlight %}
 
The example above has just a few cells and ages. In our tsetse simulation we're often looking at 120 age categories (days) on a 50x50 grid. [Here's](https://github.com/AndySouth/rtsetse/blob/master/R/rtCreateGrid.r) a function to aid creating such arrays.
 
 
### Spatial dimension trickiness
I had to be careful specifying the spatial y & x dimensions as they do not always go in the order that you might expect (and your expectations may vary depending on whether your background is more geographical or statistical !). By specifying y rather than x as the first dimension the R console displays the array in the correct orientation with x on the horizontal and y on the vertical. I started out by having x,y but kept having to transpose so decided to bite the bullet a few months in and change everything to y,x. Note that the y dimension elements start from the top which can cause other geographical issues later.
 
 
### Accessing array dimensions
This array structure allows relatively transparent access to elements and summaries as shown below.
 
An age structure for one grid cell

{% highlight r %}
aGrid['y1','x1','M',] 
{% endhighlight %}



{% highlight text %}
## age1 age2 
##   13   37
{% endhighlight %}
 
Total Males in one grid cell

{% highlight r %}
sum(aGrid['y1','x1','M',])
{% endhighlight %}



{% highlight text %}
## [1] 50
{% endhighlight %}
 
Total population in one grid cell

{% highlight r %}
sum(aGrid['y1','x1',,]) #
{% endhighlight %}



{% highlight text %}
## [1] 76
{% endhighlight %}
 
A spatial grid for one age

{% highlight r %}
aGrid[,,'M','age2']   
{% endhighlight %}



{% highlight text %}
##     x
## y    x1 x2 x3
##   y1 37 41 45
##   y2 38 42 46
##   y3 39 43 47
##   y4 40 44 48
{% endhighlight %}
 
A spatial grid of total population

{% highlight r %}
apply(aGrid,MARGIN=c('y','x'),sum) 
{% endhighlight %}



{% highlight text %}
##     x
## y    x1  x2  x3
##   y1 76  92 108
##   y2 80  96 112
##   y3 84 100 116
##   y4 88 104 120
{% endhighlight %}
 
Summed age structure for the whole population

{% highlight r %}
apply(aGrid,MARGIN=c('age'),sum) 
{% endhighlight %}



{% highlight text %}
## age1 age2 
##  300  876
{% endhighlight %}
 
Summed sex ratio for thewhole population  

{% highlight r %}
apply(aGrid,MARGIN=c('sex'),sum) 
{% endhighlight %}



{% highlight text %}
##   F   M 
## 444 732
{% endhighlight %}
 
This array also allows me to save all the population data for a simulation of a number of days by simply adding an extra dimension called day using the `abind` function from the package of the same name. Unfortunately it loses the names of the dimensions but these can be reset. The code below adds the first day as a new dimension using the `along=0` argument to abind.
 

{% highlight r %}
  library(abind)
  aRecord <- abind::abind(aGrid, along=0) 
  # replace lost dimension names
  names(dimnames(aRecord)) <- c('day','y','x','sex','age')
{% endhighlight %}
 
Records for later days (after aGrid has changed) can be added to the first dimension using the `along=1` argument :

{% highlight r %}
  aRecord <- abind::abind(aRecord, aGrid, along=1)  
  # replace lost dimension names
  names(dimnames(aRecord)) <- c('day','y','x','sex','age')
{% endhighlight %}
 
 
I have now written the code to get data from the [day,y,x,sex,age] array into a helper [function](https://github.com/AndySouth/rtsetse/blob/master/R/rtGetFromRecord.r) that I may describe in a later post.
 
Also in later posts I'll show how I represent other population processes such as movement using these arrays.
 
