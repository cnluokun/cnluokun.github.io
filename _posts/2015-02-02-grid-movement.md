---
layout: post
title: Simulating movement on a grid in R
author: Andy South
published: true
status: publish
draft: true
tags: R 
---
 
draft
 
In this post I outline a way of simulating movement on a grid in R in a time efficient way. This is part of a simulation of tsetse fly populations I've been developing. Earlier posts outline some of the [background]({% post_url 2014-12-12-rtsetse-intro %}) and use of [arrays]({% post_url 2015-01-23-simulation-arrays %}) as the main data structure.
 
My remit is to recreate in R an existing simulation developed in Excel ([Hat-trick](www.tsetse.org)) which represents a fly population on a square grid of different vegetation types. In the Excel simulation tsetse flies are represented as moving to one of the 4 cardinal neighbouring cells. The boundaries of the square area are considered to be reflective, thus assuming that cells outside of the area are similar to their neighbours within the area. Movement is also represented as being dependent upon the age & sex of flies and the vegetation within cells.  
 
A long time ago I wrote simulations of the movements of [beavers](http://www.academia.edu/2267737/Simulating_the_proposed_reintroduction_of_the_European_beaver_Castor_fiber_to_Scotland) and [raptors](https://www.academia.edu/4460440/Mate_finding_dispersal_distances_and_population_growth_in_invading_species_a_spatially_explicit_model) but they were in C and based on looping through cells. Initial reading suggested that looping in this way in R would be very slow. I then came across this nice blog post by Petr Keil : [Fast Conway's game of life in R](http://www.petrkeil.com/?p=236). In it he demonstrates a quick way of simulating movement that takes advantage of R's efficient matrix operations. 
 
### A mechanism for simulating movement on a grid
 
1. create a shifted copy of the grid for each direction that you want to allow movement in (4 grids if NSEW, 8 grids if including diagonals).
1. calculate the number of arrivers in all cells on the grid by 
   + adding the grids together 
   + multiply by the proportion moving
   + divide by the number of neighbours (4 if NSEW, 8 if including diagonals)
1. calculate the number staying in all cells by multiplying the original grid by 1 minus the proportion moving 
1. get the new distribution by adding the grids for arrivers and stayers
 
This is the bare code for an island model in which no movers come in from outside and any leaving are lost to the population: 
 

{% highlight r %}
  #create a starting matrix and proportion moving
  m <- matrix(c(0,0,0,0,1,0,0,0,0),nrow=3,ncol=3)
  pMove <- 0.4
 
  #island model uses 0's for boundary cells
  mW = cbind( rep(0,nrow(m)), m[,-ncol(m)] )
  mN = rbind( rep(0,ncol(m)), m[-nrow(m),] )
  mE = cbind( m[,-1], rep(0,nrow(m)) )
  mS = rbind( m[-1,], rep(0,ncol(m)) )
 
  #calc arrivers in a cell from it's 4 neighbours
  mArrivers <- pMove*(mN + mE + mS + mW)/4
  mStayers <- (1-pMove)*m
  
  mNew <- mArrivers + mStayers
{% endhighlight %}
 
Viewing the result.

{% highlight r %}
  mNew
{% endhighlight %}



{% highlight text %}
##      [,1] [,2] [,3]
## [1,]  0.0  0.1  0.0
## [2,]  0.1  0.6  0.1
## [3,]  0.0  0.1  0.0
{% endhighlight %}
 
 
Below this idea is used to create functions that accept :
1. m : a 2D matrix (y,x) of the spatial distribution of the population
1. pMove : the proportion of the population moving in a timestep
 
and return the new spatial distribution of the population.
 
Note that these versions are deterministic, because that is what I have been tasked to create for the tsetse simulation, but that it would be easy to modify to make movement stochastic determined by a movement probability.
 
 
### An island-model of movement
 

{% highlight r %}
rtMoveIsland <- function(m, pMove=0.4) {
  
  #speed efficient way of doing movement
  #create a copy of the matrix shifted 1 cell in each cardinal direction
  #island model uses 0's for boundary cells
  mW = cbind( rep(0,nrow(m)), m[,-ncol(m)] )
  mN = rbind( rep(0,ncol(m)), m[-nrow(m),] )
  mE = cbind( m[,-1], rep(0,nrow(m)) )
  mS = rbind( m[-1,], rep(0,ncol(m)) )
 
  #calc arrivers in a cell from it's 4 neighbours
  mArrivers <- pMove*(mN + mE + mS + mW)/4
  mStayers <- (1-pMove)*m
  
  mNew <- mArrivers + mStayers
  
  return( mNew )
}
{% endhighlight %}
 
 
### A reflecting boundaries model of movement
 

{% highlight r %}
rtMoveReflect <- function(m, pMove=0.4) {
  
  #speed efficient way of doing movement
  #create a copy of the matrix shifted 1 cell in each cardinal direction
  #reflecting boundaries
  #0's from island model above are replaced with a copy of boundary row or col
  mW = cbind( m[,1], m[,-ncol(m)] )
  mN = rbind( m[1,], m[-nrow(m),] )
  mE = cbind( m[,-1], m[,ncol(m)] )
  mS = rbind( m[-1,], m[nrow(m),] ) 
  
  #calc arrivers in a cell from it's 4 neighbours
  mArrivers <- pMove*(mN + mE + mS + mW)/4
  mStayers <- (1-pMove)*m
  
  mNew <- mArrivers + mStayers
  
  return( mNew )
}
{% endhighlight %}
 
Just looking back at the original post now I see that Kiran Dhanjal-Adams has adapted the special case of the Game of Life to work with [reflecting boundaries](https://uqkdhanj.wordpress.com/2014/10/20/getting-started-with-r/).
 
 
The movement functions shown above can be called over multiple time steps as shown below.
 

{% highlight r %}
nY <- 6
nX <- 5
nDays <- 12
#create arrays to store results
aIsland <- aReflect <- array(0, dim=c(nY, nX, nDays))
 
#populate central cell of starting grid on day1
aIsland[3,2,1] <- aReflect[3,2,1] <- 1
#set proportion moving
pMove <- 0.4
 
for(day in 2:nDays)
{
  aIsland[,,day] <- rtMoveIsland(aIsland[,,day-1], pMove=pMove)  
  aReflect[,,day] <- rtMoveReflect(aReflect[,,day-1], pMove=pMove)
    
}
 
#quick way of displaying the resulting arrays
require(raster)
plot( raster::brick(aIsland), axes=FALSE, main="island movement" )
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-1.png) 

{% highlight r %}
#round(mIsland,2)
 
plot( raster::brick(aReflect), axes=FALSE, main="reflecting movement" )
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-2.png) 

{% highlight r %}
#round(mReflect,2)
{% endhighlight %}
 
 
 
I've also modified these movement functions to account for no-go areas and vegetation effects on movement. I'll describe these in a later post.
 
 
 
 
 
 
 
 
