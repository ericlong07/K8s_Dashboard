# Use the official R base image
FROM r-base:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev

# Install R packages required for the Shiny application
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'readr', 'plotly', 'ggplot2', 'DT'), repos='https://cran.rstudio.com/')"

# Copy the Shiny application files to the Docker container
COPY app.R /app/
COPY www /app/www

# Set the working directory
WORKDIR /app

# Expose the Shiny application port (change the port number if needed)
EXPOSE 3838

# Run the Shiny application
CMD ["R", "-e", "shiny::runApp(host = '0.0.0.0', port = 3838)"]
