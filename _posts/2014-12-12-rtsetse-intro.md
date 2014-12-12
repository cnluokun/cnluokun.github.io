---
layout: post
title: An introduction to rtsetse, a detailed population simulation in R
author: Andy South
published: true
status: publish
tags: R 
---
 
In this post I introduce newly developed R code to simulate tsetse fly populations developed for the [Liverpool School for Tropical Medicine](http://www.lstmed.ac.uk/) starting in 2014. I will outline some background here and point you to the code and user interface that are under development. In subsequent posts I'll cover particular aspects of implementation.
 
 
African sleeping sickness is a serious disease caused by a trypanosome parasite transmitted by tsetse flies. Tsetse flies are themselves interesting as they feed entirely on blood, don't have aquatic larvae and females produce a small number of larvae one at a time. Three common options for controlling tsetse flies and the disease are aerial spraying, treating cattle with insecticides and putting out small baited traps (somewhat like a handkerchief).  
 
 
Glyn Vale and [Steve Torr](http://www.lstmed.ac.uk/research/departments/staff-profiles/steve-torr/) are leading researchers in the development of baits for controlling tsetse flies. Over the past 10 years they have developed a series of Excel based [decision tools](http://www.tsetse.org/tools/index.html) for tsetse control.
 
 
I was tasked with creating a spatial, age and sex structured simulation of tsetse fly populations in R based upon [Hat-trick](http://www.tsetse.org/trick/index.html), the most recent and detailed of these Excel tools. Hat-Trick consists of around 10 Excel workbooks linked by VBA code. Some workbooks have tens of worksheets and the longest sheet has 20,000 rows. Hat-trick steps the user through a series of detailed modelling steps with plenty of documentation. The amount of detail inevitably makes the model very complicated. The aim of developing the replacement in R was to develop something that was more robust, transparent and reproducible.
 
 
My task was to develop both a core simulation and a user-interface.
 
In tackling
 
 
 
 
 
 
