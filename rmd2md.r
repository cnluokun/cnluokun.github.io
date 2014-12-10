#' This R script will process all R mardown files (those with in_ext file extention,
#' .rmd by default) in the current working directory. Files with a status of
#' 'processed' will be converted to markdown (with out_ext file extention, '.markdown'
#' by default). It will change the published parameter to 'true' and change the
#' status parameter to 'publish'.
#' 
#' @param dir the directory to process R Markdown files.
#' @param images.dir the base directory where images will be generated.
#' @param images.url
#' @param out_ext the file extention to use for processed files.
#' @param in_ext the file extention of input files to process.
#' @param recursive should rmd files in subdirectories be processed.
#' @return nothing.
#' @author Jason Bryer <jason@bryer.org> edited by Andy South
rmd2md <- function( path_site = getwd(),
                              dir_rmd = "_rmd",
                              dir_md = "_posts",                              
                              #dir_images = "figures",
                              url_images = "figures/",
                              out_ext='.md', 
                              in_ext='.rmd', 
                              recursive=FALSE) {
  
  require(knitr, quietly=TRUE, warn.conflicts=FALSE)

  #files <- list.files(path=dir, pattern=in_ext, ignore.case=TRUE, recursive=recursive)
  #andy change to avoid path problems when running without sh on windows 
  #files <- list.files(path=pathSite, full.names=TRUE, pattern=in_ext, ignore.case=TRUE, recursive=recursive)
  files <- list.files(path=file.path(path_site,dir_rmd), pattern=in_ext, ignore.case=TRUE, recursive=recursive)
  
  for(f in files) {
    message(paste("Processing ", f, sep=''))
    content <- readLines(file.path(path_site,dir_rmd,f))
    frontMatter <- which(substr(content, 1, 3) == '---')
    if(length(frontMatter) >= 2 & 1 %in% frontMatter) {
      statusLine <- which(substr(content, 1, 7) == 'status:')
      publishedLine <- which(substr(content, 1, 10) == 'published:')
      if(statusLine > frontMatter[1] & statusLine < frontMatter[2]) {
        status <- unlist(strsplit(content[statusLine], ':'))[2]
        status <- sub('[[:space:]]+$', '', status)
        status <- sub('^[[:space:]]+', '', status)
        if(tolower(status) == 'process') {
          #This is a bit of a hack but if a line has zero length (i.e. a
          #black line), it will be removed in the resulting markdown file.
          #This will ensure that all line returns are retained.
          content[nchar(content) == 0] <- ' '
          message(paste('Processing ', f, sep=''))
          content[statusLine] <- 'status: publish'
          content[publishedLine] <- 'published: true'
          
          #outFile <- paste(substr(f, 1, (nchar(f)-(nchar(in_ext)))), out_ext, sep='')
          outFile <- file.path(path_site, dir_md, paste0(substr(f, 1, (nchar(f)-(nchar(in_ext)))), out_ext))
          
          
          #render_markdown(strict=TRUE)
          #andy added from elsewhere, does it do anything ?
          render_jekyll(highlight = "pygments")
          
          opts_knit$set(out.format='markdown') 
          
          # "base.dir is never used when composing the URL of the figures; it is 
          # only used to save the figures to a different directory. 
          # The URL of an image is always base.url + fig.path"
          # https://groups.google.com/forum/#!topic/knitr/18aXpOmsumQ
          
          #andy adding this to try to fix relative path problems
          #opts_knit$set(root.dir=path_site)  
          #opts_knit$set(verbose=TRUE)  
          
          #BEWARE don't set base.dir!! it seems not to do what you'd expect
          #opts_knit$set(base.dir=dir_images)
          #opts_knit$set(base.dir=file.path(path_site, dir_images))
          
          opts_knit$set(base.url = "/")
          opts_chunk$set(fig.path = url_images)                     

          #opts_knit$set(base.url=images.url)
          #opts_knit$set(base.url=file.path(path_site, dir_images))
          ##opts_knit$set(base.url="/")
          
          try(knit(text=content, output=outFile), silent=FALSE)
        } else {
          warning(paste("Not processing ", f, ", status is '", status, 
                        "'. Set status to 'process' to convert.", sep=''))
        }
      } else {
        warning("Status not found in front matter.")
      }
    } else {
      warning("No front matter found. Will not process this file.")
    }
  }
  invisible()
}