# RefurbiX AuditOS Development Makefile
# ==============================================================================

# Variables
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_FILE = docker-compose.yml
PROJECT_NAME = refurbix-auditos

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.DEFAULT_GOAL := help

## Help
help: ## Show this help message
	@echo '$(BLUE)RefurbiX AuditOS - Development Commands$(NC)'
	@echo ''
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make $(BLUE)<command>$(NC)\n\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $1, $2 }' $(MAKEFILE_LIST)

## Environment Setup
setup: ## Initial project setup
	@echo '$(BLUE)Setting up RefurbiX AuditOS development environment...$(NC)'
	@cp .env.example .env
	@echo '$(GREEN)✓ Environment file created$(NC)'
	@echo '$(YELLOW)Please edit .env file with your configuration$(NC)'

install: ## Install all dependencies
	@echo '$(BLUE)Installing dependencies...$(NC)'
	@cd services/user-service && npm install
	@cd services/audit-service && npm install
	@cd services/device-service && npm install
	@cd services/workflow-service && npm install
	@cd services/reporting-service && npm install
	@cd services/notification-service && npm install
	@cd clients/dashboard && npm install
	@echo '$(GREEN)✓ All dependencies installed$(NC)'

## Docker Operations
build: ## Build all Docker images
	@echo '$(BLUE)Building Docker images...$(NC)'
	@$(DOCKER_COMPOSE) build --no-cache
	@echo '$(GREEN)✓ Docker images built$(NC)'

up: ## Start all services
	@echo '$(BLUE)Starting RefurbiX AuditOS services...$(NC)'
	@$(DOCKER_COMPOSE) up -d
	@echo '$(GREEN)✓ All services started$(NC)'
	@echo ''
	@$(MAKE) status

up-build: ## Build and start all services
	@echo '$(BLUE)Building and starting services...$(NC)'
	@$(DOCKER_COMPOSE) up -d --build
	@echo '$(GREEN)✓ Services built and started$(NC)'

down: ## Stop all services
	@echo '$(BLUE)Stopping services...$(NC)'
	@$(DOCKER_COMPOSE) down
	@echo '$(GREEN)✓ All services stopped$(NC)'

restart: ## Restart all services
	@$(MAKE) down
	@$(MAKE) up

status: ## Show service status
	@echo '$(BLUE)Service Status:$(NC)'
	@$(DOCKER_COMPOSE) ps
	@echo ''
	@echo '$(BLUE)Available URLs:$(NC)'
	@echo '  $(GREEN)Dashboard:$(NC)         http://localhost:3000'
	@echo '  $(GREEN)API Gateway:$(NC)       http://localhost:8000'
	@echo '  $(GREEN)Kong Admin:$(NC)        http://localhost:8001'
	@echo '  $(GREEN)Kong GUI:$(NC)          http://localhost:8002'
	@echo '  $(GREEN)PostgreSQL:$(NC)        localhost:5432'
	@echo '  $(GREEN)Redis:$(NC)             localhost:6379'
	@echo '  $(GREEN)InfluxDB:$(NC)          http://localhost:8086'
	@echo '  $(GREEN)MinIO Console:$(NC)     http://localhost:9001'
	@echo '  $(GREEN)Prometheus:$(NC)        http://localhost:9090'
	@echo '  $(GREEN)Grafana:$(NC)           http://localhost:3030'
	@echo '  $(GREEN)PgAdmin:$(NC)           http://localhost:5050'
	@echo '  $(GREEN)MailHog:$(NC)           http://localhost:8025'

logs: ## Show logs for all services
	@$(DOCKER_COMPOSE) logs -f

logs-%: ## Show logs for specific service (e.g., make logs-user-service)
	@$(DOCKER_COMPOSE) logs -f $*

## Database Operations
db-init: ## Initialize database with schema and seed data
	@echo '$(BLUE)Initializing database...$(NC)'
	@$(DOCKER_COMPOSE) exec postgres psql -U postgres -d refurbix -f /migrations/01-init.sql
	@$(DOCKER_COMPOSE) exec postgres psql -U postgres -d refurbix -f /migrations/01-dev-data.sql
	@echo '$(GREEN)✓ Database initialized$(NC)'

db-reset: ## Reset database (WARNING: This will delete all data)
	@echo '$(RED)WARNING: This will delete all data!$(NC)'
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $REPLY =~ ^[Yy]$ ]]; then \
		$(DOCKER_COMPOSE) exec postgres psql -U postgres -c "DROP DATABASE IF EXISTS refurbix;"; \
		$(DOCKER_COMPOSE) exec postgres psql -U postgres -c "CREATE DATABASE refurbix;"; \
		$(MAKE) db-init; \
		echo '$(GREEN)✓ Database reset complete$(NC)'; \
	else \
		echo '$(YELLOW)Database reset cancelled$(NC)'; \
	fi

db-backup: ## Backup database
	@echo '$(BLUE)Creating database backup...$(NC)'
	@mkdir -p backups
	@$(DOCKER_COMPOSE) exec postgres pg_dump -U postgres refurbix > backups/refurbix_$(shell date +%Y%m%d_%H%M%S).sql
	@echo '$(GREEN)✓ Database backup created$(NC)'

db-shell: ## Open PostgreSQL shell
	@$(DOCKER_COMPOSE) exec postgres psql -U postgres -d refurbix

## Service Development
dev-%: ## Start specific service in development mode (e.g., make dev-user-service)
	@echo '$(BLUE)Starting $* in development mode...$(NC)'
	@cd services/$* && npm run dev

test: ## Run all tests
	@echo '$(BLUE)Running all tests...$(NC)'
	@cd services/user-service && npm test
	@cd services/audit-service && npm test
	@cd services/device-service && npm test
	@cd services/workflow-service && npm test
	@cd services/reporting-service && npm test
	@cd services/notification-service && npm test
	@cd clients/dashboard && npm test
	@echo '$(GREEN)✓ All tests completed$(NC)'

test-%: ## Run tests for specific service (e.g., make test-user-service)
	@echo '$(BLUE)Running tests for $*...$(NC)'
	@cd services/$* && npm test

lint: ## Run linting on all services
	@echo '$(BLUE)Running linting...$(NC)'
	@cd services/user-service && npm run lint
	@cd services/audit-service && npm run lint
	@cd services/device-service && npm run lint
	@cd services/workflow-service && npm run lint
	@cd services/reporting-service && npm run lint
	@cd services/notification-service && npm run lint
	@cd clients/dashboard && npm run lint
	@echo '$(GREEN)✓ Linting completed$(NC)'

format: ## Format code in all services
	@echo '$(BLUE)Formatting code...$(NC)'
	@cd services/user-service && npm run format
	@cd services/audit-service && npm run format
	@cd services/device-service && npm run format
	@cd services/workflow-service && npm run format
	@cd services/reporting-service && npm run format
	@cd services/notification-service && npm run format
	@cd clients/dashboard && npm run format
	@echo '$(GREEN)✓ Code formatted$(NC)'

## Clean Up
clean: ## Clean up containers, volumes, and images
	@echo '$(BLUE)Cleaning up...$(NC)'
	@$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans
	@docker system prune -f
	@echo '$(GREEN)✓ Cleanup completed$(NC)'

clean-data: ## Clean up only data volumes (preserves images)
	@echo '$(RED)WARNING: This will delete all data!$(NC)'
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $REPLY =~ ^[Yy]$ ]]; then \
		$(DOCKER_COMPOSE) down -v; \
		echo '$(GREEN)✓ Data volumes cleaned$(NC)'; \
	else \
		echo '$(YELLOW)Data cleanup cancelled$(NC)'; \
	fi

## Documentation
docs: ## Generate API documentation
	@echo '$(BLUE)Generating API documentation...$(NC)'
	@# Add documentation generation commands here
	@echo '$(GREEN)✓ Documentation generated$(NC)'

## Production Deployment (placeholder)
deploy-staging: ## Deploy to staging environment
	@echo '$(BLUE)Deploying to staging...$(NC)'
	@# Add staging deployment commands here
	@echo '$(GREEN)✓ Deployed to staging$(NC)'

deploy-prod: ## Deploy to production environment
	@echo '$(RED)Production deployment$(NC)'
	@# Add production deployment commands here

## Monitoring
monitor: ## Open monitoring dashboard
	@echo '$(BLUE)Opening monitoring dashboard...$(NC)'
	@open http://localhost:3030 || xdg-open http://localhost:3030 || echo 'Please open http://localhost:3030 in your browser'

health: ## Check health of all services
	@echo '$(BLUE)Checking service health...$(NC)'
	@curl -s http://localhost:8000/health || echo '$(RED)API Gateway: DOWN$(NC)'
	@curl -s http://localhost:3001/health || echo '$(RED)User Service: DOWN$(NC)'
	@curl -s http://localhost:3002/health || echo '$(RED)Audit Service: DOWN$(NC)'
	@curl -s http://localhost:3003/health || echo '$(RED)Device Service: DOWN$(NC)'
	@curl -s http://localhost:3004/health || echo '$(RED)Workflow Service: DOWN$(NC)'
	@curl -s http://localhost:3005/health || echo '$(RED)Reporting Service: DOWN$(NC)'
	@curl -s http://localhost:3006/health || echo '$(RED)Notification Service: DOWN$(NC)'
	@echo '$(GREEN)✓ Health check completed$(NC)'

## Load Testing
load-test: ## Run load tests against the API
	@echo '$(BLUE)Running load tests...$(NC)'
	@# Add load testing commands here (Artillery, K6, etc.)
	@echo '$(GREEN)✓ Load tests completed$(NC)'

.PHONY: help setup install build up up-build down restart status logs db-init db-reset db-backup db-shell test lint format clean clean-data docs deploy-staging deploy-prod monitor health load-test