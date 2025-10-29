# Movie Analyst Application Infrastructure Diagram

```
                            ┌─────────────────────────────────────┐
                            │           INTERNET                  │
                            └─────────────────┬───────────────────┘
                                              │
                    ┌─────────────────────────▼──────────────────────┐
                    │        Load Balancer (HTTP/S)                  │
                    │        External IP: 34.107.139.237             │
                    └─────────────────┬──────────────────────────────┘
                                      │
                    ┌─────────────────▼──────────────────────┐
                    │           Frontend VM                   │
                    │        frontend-qa-vpr8                  │
                    │         10.0.2.3 (private)               │
                    │                                          │
                    │  ┌──────────────────────────────┐        │
                    │  │    Node.js/Express App       │        │
                    │  │   (movie-analyst-ui)         │        │
                    │  │    Port: 3030                │        │
                    │  │   Serves Web UI              │        │
                    │  └──────────────────────────────┘        │
                    └─────────────────┬──────────────────────┘
                                      │
                    ┌─────────────────▼──────────────────────┐
                    │           Backend VM                   │
                    │           backend-qa                   │
                    │         10.0.2.2 (private)               │
                    │                                          │
                    │  ┌──────────────────────────────┐        │
                    │  │    Node.js/Express API       │        │
                    │  │   (movie-analyst-api)        │        │
                    │  │    Port: 3000                │        │
                    │  │   Exposes REST API           │        │
                    │  └──────────────────────────────┘        │
                    │                                          │
                    │  ┌──────────────────────────────┐        │
                    │  │    Cloud SQL Proxy           │        │
                    │  │   (localhost:3306)           │        │
                    │  └──────────────────────────────┘        │
                    └─────────────────┬──────────────────────┘
                                      │
                    ┌─────────────────▼──────────────────────┐
                    │        Cloud SQL Database              │
                    │         movie-db-qa                   │
                    │    Private IP: 10.3.30.5               │
                    │    ┌──────────────────────────┐       │
                    │    │      Database Tables     │       │
                    │    │  - movies                │       │
                    │    │  - publications          │       │
                    │    │  - reviewers             │       │
                    │    └──────────────────────────┘       │
                    └────────────────────────────────────────┘

                            ┌─────────────────────────────────────┐
                            │           Bastion VM               │
                            │           bastion-qa               │
                            │   External IP: 34.61.107.53        │
                            │   Internal IP: 10.0.1.2            │
                            │                                    │
                            │  Used for secure SSH access to    │
                            │  private instances                 │
                            └────────────────────────────────────┘

    VPC Network: movie-analyst-vpc-qa
    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                     │
    │  Public Subnet: 10.0.1.0/24                                         │
    │  ┌─────────────────────────────────────────────────────────────┐   │
    │  │  Bastion VM                                                 │   │
    │  │  - bastion-qa                                               │   │
    │  └─────────────────────────────────────────────────────────────┘   │
    │                                                                     │
    │  Private Subnet: 10.0.2.0/24                                        │
    │  ┌─────────────────────────────────────────────────────────────┐   │
    │  │  Application VMs                                            │   │
    │  │  - backend-qa (10.0.2.2)                                    │   │
    │  │  - frontend-qa-vpr8 (10.0.2.3)                              │   │
    │  └─────────────────────────────────────────────────────────────┘   │
    │                                                                     │
    │  Cloud SQL Subnet: 10.3.30.0/24                                     │
    │  ┌─────────────────────────────────────────────────────────────┐   │
    │  │  Database                                                   │   │
    │  │  - movie-db-qa (10.3.30.5)                                  │   │
    │  └─────────────────────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────────────────────┘

Legend:
──────  Network Traffic
══════  Database Connection (through Cloud SQL Proxy)
::::::  SSH Tunnel (through Bastion)

Connections:
1. Internet → Load Balancer: HTTP/S traffic
2. Load Balancer → Frontend VM: HTTP traffic (port 3030)
3. Frontend VM → Backend VM: HTTP traffic (port 3000)
4. Backend VM → Cloud SQL: Database connection through Cloud SQL Proxy
5. Bastion VM ←→ All VMs: SSH access for administration
```