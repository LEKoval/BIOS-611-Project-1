FROM rocker/verse
MAINTAINER Lauren Koval <lkoval@unc.edu>
RUN R -e "install.packages('gridExtra')"
RUN R -e "install.packages('gbm')"
