---
layout: post
title: Setting up this blog with Jekyll, R, RMarkdown and RStudio.
author: Andy South
published: true
status: publish
tags: R Jekyll RStudio
---
 
In this first post of this new blog I'll outline how I've set it up.
 
## What I wanted
I wanted to be able to write about R related things without having to copy and paste code, figures or files. I had used [Rmarkdown](http://rmarkdown.rstudio.com/) and [knitr](http://yihui.name/knitr/) before so wanted to use them. I have a wordpress site elsewhere that someone helped me set up a couple of years ago with a blog that I've never used. Initially I tried seeing if I could create posts using RMarkdown and put them into that wordpress blog. A brief search revealed that was not straightforward and that Jekyll was the way to go.  
 
## What I've got
Now I have this blog set up so that I can write all of the posts (including this one) in RMarkdown (Rmd) and run an R function to convert them to markdown (md). The blog is hosted for free on [Github](https://github.com/) (you get one free personal site). The site is created using [Jekyll](http://jekyllrb.com/) on Github, so I didn't need to install Jekyll or Ruby. I simply edit files locally, then commit and push to Github. I manage the site as an [RStudio](http://www.rstudio.com/products/RStudio) project, enabling me to edit text, keep track of files and interact with Git all from one interface.  
 
## How I got here (steps)
 
### creating Jekyll site on Github
I used Barry Clarks amazing [Jekyll Now repository](https://github.com/barryclark/jekyll-now) which you can fork directly from Github and start editing to customize. He gives excellent instructions. What attarcted me to it was that it takes a matter of minutes to set up initially and if you decide you don't like it you can just delete.  
 
Thanks to Jan Gorecki who answered a stackoverflow question that pointed me in this direction and I've copied some extra features like the Links and Index pages from his [site](https://github.com/jangorecki/jangorecki.github.io).  
 
### enabling editing of the site from RStudio
I cloned the Github repository for my site using RStudio :
File, New project, Version control, Clone git
Repo URL : https://github.com/AndySouth/andysouth.github.io
Project directory name : andysouth.github.io
 
 
### setting up so that I can write the posts in RMarkdown
This was the tricky bit for me. I followed inspiration from [Jason Bryer](http://jason.bryer.org/posts/2012-12-10/Markdown_Jekyll_R_for_Blogging.html) and [Jon Zelner](http://www.jonzelner.net/jekyll/knitr/r/2014/07/02/autogen-knitr/). I had to tweak them both, the relative paths of figures was my main stumbling block. This was partly because I'm running windows and I couldn't run the shell scripts that they created. Instead I just run an R function [rmd2md](https://github.com/AndySouth/andysouth.github.io/blob/master/rmd2md.r) which is much the same as Jason's with some edits to paths. The most important bits are :
 
 

{% highlight r %}
          render_jekyll(highlight = "pygments")
                    
          opts_knit$set(base.url = "/")
          opts_chunk$set(fig.path = url_images)                     
          
          try(knit(text=content, output=outFile), silent=FALSE)
{% endhighlight %}
 
Jason's function searches a folder that you specify for Rmd files and then puts md files into another folder. I set this up so that any plots are put into a third folder. Thus in the root of my site includes these 3 folders.
 
| Folder | Contents |
| ------ | --- |
| _Rmd   | the RMarkdown files that I edit |
| _md    | the md files created by RMarkdown |
| figures | the plots created by any chunks of R code |
 
This then means that any R plot is automatically generated, saved as a png and it's address is written into the md document so that the plot is displayed in the blog, as shown in the very simple example below.
 
![plot of chunk unnamed-chunk-2](/figures/unnamed-chunk-2-1.png) 
 
