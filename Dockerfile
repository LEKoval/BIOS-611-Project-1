FROM rocker/verse
MAINTAINER Lauren Koval <lkoval@unc.edu>
RUN R -e "install.packages('gridExtra')"
RUN R -e "install.packages('gbm')"
RUN R -e "install.packages('factoextra')"
RUN R -e "install.packages('MLmetrics')"
RUN R -e "install.packages('ggfortify')"
RUN apt update -y && apt install -y python3-pip
RUN pip3 install jupyter jupyterlab
RUN pip3 install numpy pandas sklearn plotnine matplotlib
RUN R -e "install.packages('caret')"
RUN R -e "install.packages('e1071')"
