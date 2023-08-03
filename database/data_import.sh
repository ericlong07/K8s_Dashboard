#!/bin/bash

# Wait for PostgreSQL to be ready
sleep 10

# Create the table if it doesn't exist
psql -U postgres -d postgres << EOF
CREATE TABLE IF NOT EXISTS slurm_data (
    RowIndex numeric,
    AllocCPUS numeric,
    AllocNodes numeric,
    AveCPU numeric,
    AveDiskRead numeric,
    AveDiskWrite numeric,
    AveRSS numeric,
    CPUTime text,
    CPUTimeRAW numeric,
    Elapsed text,
    ElapsedRaw numeric,
    "End" timestamp,
    ExitCode text,
    JobID text,
    JobIDRaw integer,
    NCPUS integer,
    NNodes integer,
    NodeList text,
    NTasks integer,
    "Partition" text,
    ReqCPUS integer,
    ReqMem text,
    ReqNodes integer,
    "Start" timestamp,
    "Submit" timestamp,
    TotalCPU text
);
EOF

# Truncate the table (remove all existing rows)
psql -U postgres -d postgres -c "TRUNCATE TABLE slurm_data;"

# Import data from CSV
psql -U postgres -d postgres -c "\COPY slurm_data FROM '/var/lib/postgresql/data/slurm_data/Jul2018.csv' DELIMITER ',' CSV HEADER;"
