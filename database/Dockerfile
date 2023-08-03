# Use the official PostgreSQL image as the base image
FROM postgres:latest

# Set the PostgreSQL superuser password
ENV POSTGRES_PASSWORD=mysecretpassword

# Expose the PostgreSQL default port
EXPOSE 5432

# Create a directory inside the container for the PGDATA
RUN mkdir -p /var/lib/postgresql/data/pg_data

# Create a directory inside the container for the CSV data
RUN mkdir -p /var/lib/postgresql/data/slurm_data

# Copy the CSV data into the container's data folder
COPY ./data/Jul2018.csv /var/lib/postgresql/data/slurm_data/

# Copy the data import script to the container's working directory
COPY ./data_import.sh /docker-entrypoint-initdb.d/

# Make sure the data_import.sh script has execute permissions
RUN chmod +x /docker-entrypoint-initdb.d/data_import.sh
