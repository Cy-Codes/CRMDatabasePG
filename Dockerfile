FROM postgres:16-alpine

LABEL maintainer="Enterprise CRM Engineering Team"
LABEL description="PostgreSQL CRM Database with Migration-Based Versioning (Salesforce, HubSpot, Dynamics 365)"

# Install bash and client tools
RUN apk add --no-cache bash python3

ENV POSTGRES_DB=CRMDatabase
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV SEED_DATA=standard

# Copy migration scripts and initialization hooks
WORKDIR /workspace
COPY migrations/ /workspace/migrations/
COPY scripts/ /workspace/scripts/
COPY tests/ /workspace/tests/
COPY migrate.sh /workspace/migrate.sh
COPY entrypoint.sh /docker-entrypoint-initdb.d/99_crm_init.sh

RUN chmod +x /workspace/migrate.sh /workspace/tests/run_tests.sh /docker-entrypoint-initdb.d/99_crm_init.sh

EXPOSE 5432
