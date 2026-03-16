
# Python Development & Testing Best Practices

## Overview

This document outlines best practices for Python development and testing at our organization. It serves as a guide for all team members to ensure code quality, maintainability, scalability, and operational excellence.

---

## 1. Development Environment Setup

### 1.1 Python Version Management

- Use **Python 3.10+** as the minimum supported version (EOL considerations)
- Use `pyenv` or `asdf` for managing multiple Python versions locally
- Always pin Python version in:
  - `pyproject.toml` (under `[project]` or `[tool.poetry]`)
  - `Dockerfile` (use specific version tags, not `latest`)
  - `.python-version` file in the repository root

### 1.2 Dependency Management

- Use **uv** (not pip) for reproducible builds
  - `pyproject.toml` for dependencies and metadata
  - Lock files (`poetry.lock` or `uv.lock`) must be committed to version control
- Pin major versions in `pyproject.toml`; allow minor/patch updates
- Regularly audit dependencies for security vulnerabilities:
  - Use `pip-audit`, `safety`, or `dependabot`
  - Automate this in CI/CD pipelines

### 1.3 Virtual Environments

- Always use **uv** for virtual environments (never install globally)
- One virtual environment per project
- Document setup in `README.md`:

```bash
uv init #Initialise a project in the current directory
uv init myproj #Initialise a project myproj in the directory myproj
uv init --app --package  #Initialise a packageable app (e.g., CLI, web app, ...)
uv init --lib --package #Initialise a packageable library (code you import)
uv init --python 3.X #Use Python 3.X for your project

uv add requests #Add requests as a dependency
uv add A B C #Add A, B, and C as dependencies
uv add -r requirements.txt #Add dependencies from the file requirements.txt
uv add --dev pytest #Add pytest as a development dependency
uv run pytest #Run the pytest executable that is installed in your project
uv remove requests #Remove requests as a dependency
uv remove A B C #Remove A, B, C, and their transitive dependencies
uv tree #See the project dependencies tree
uv lock --upgrade #Upgrade the dependencies' versions

uv build #Build your packageable project
uv publish #Publish your packageable project to PyPI
uv version #Check your project version
```

## 2 Code Style & Formatting

### 2.1 Code Standards

- Follow PEP 8 as the baseline; use PEP 20 (The Zen of Python) as philosophy
- Use Black for automatic code formatting (non-negotiable)
- Configure in pyproject.toml: line-length = 100
- Run on every commit via pre-commit hooks
  
### 2.2 Linting & Static Analysis

- Ruff: Fast, Python-native linter (replaces flake8, isort, etc.)
- Configure rules in pyproject.toml
- Run in CI/CD as a gate
- MyPy: Static type checker for Python
- Enable strict mode: --strict
- Gradually migrate legacy code to full type coverage
- Pylint (optional): Additional code quality checks for complex logic

### 2.3 Pre-commit Hooks

- Automate checks before commits:

``` yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.10.0
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.0
    hooks:
      - id: ruff
        args: [--fix]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.5.1
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
```

### 2.4 Code Organization

- Monorepo structure (for multiple related services)
  
``` Tree
  repo/
  ├── services/
  │   ├── auth-service/
  │   │   ├── src/
  │   │   ├── tests/
  │   │   └── pyproject.toml
  │   └── api-service/
  ├── shared/
  │   ├── models/
  │   └── utils/
  └── pyproject.toml (workspace)
```

- Single-service structure:

``` Tree
  repo/
    ├── src/
    │   └── myapp/
    │       ├── __init__.py
    │       ├── api/
    │       ├── models/
    │       ├── services/
    │       └── utils/
    ├── tests/
    ├── docs/
    └── pyproject.toml
```

## 3. Type Hints and Type Safety

## 3.1 Mandatory Type Hints

- Type hint all function arguments and return types

``` python
from typing import Optional, List
from datetime import datetime

def process_user(user_id: int, tags: Optional[List[str]] = None) -> dict:
    """Process user data."""
    return {}
```

- Use **TypedDict** for structured dictionaries:

``` python
from typing import TypedDict

class UserData(TypedDict):
    id: int
    name: str
    email: str
```

- Use Pydantic for data validation in APIs/services:

``` python
from pydantic import BaseModel, Field, validator

class UserCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    email: str
    
    @validator('email')
    def validate_email(cls, v):
        assert '@' in v
        return v
```

## 3.2 MyPy Configuration

``` toml
# pyproject.toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
follow_imports = "normal"
```

## 4. Testing Strategy

### 4.1 Unit Testing

- Framework: Use pytest (de facto standard)
  - Simpler than unittest
  - Better fixtures and parametrization
  - Rich plugin ecosystem
- Minimum Coverage: 80% code coverage (aim for 85%+)
  - Configure in pyproject.toml:

  ``` toml
  [tool.pytest.ini_options]
  minversion = "7.0"
  addopts = "--cov=src --cov-report=html --cov-fail-under=80"
  testpaths = ["tests"]
  python_files = "test_*.py"
  ```

- Structure

``` python
# tests/unit/services/test_user_service.py
import pytest
from unittest.mock import Mock, patch
from src.services.user_service import UserService

@pytest.fixture
def user_service():
    """Fixture for UserService."""
    return UserService(db=Mock())

class TestUserService:
    def test_create_user_success(self, user_service):
        """Test successful user creation."""
        result = user_service.create_user(name="John", email="john@example.com")
        assert result.id is not None
        assert result.name == "John"
    
    def test_create_user_invalid_email(self, user_service):
        """Test user creation with invalid email."""
        with pytest.raises(ValueError):
            user_service.create_user(name="John", email="invalid")
  ```

- Mocking Best Practices
  - Mock external dependencies (APIs, databases, services)
  - Use **unittest.mock** or **pytest-mock**
  - Mock at module boundaries, not internal functions

``` python
@patch('src.services.user_service.external_api.fetch_user_profile')
def test_with_mock(self, mock_api):
    mock_api.return_value = {"status": "success"}
    # Test code here
```

## 5. Documentation

### 5.1 READEME.MD (Required)

- Every repository must include a README.md with:

``` markdown
# Project Name

Brief description.

## Installation
Instructions for local setup.

## Development
How to run tests, linting, and the development server.

## Deployment
How to deploy to production.

## Architecture
High-level architecture diagram and decisions.

## Contributing
Link to CLAUDE.md and code review process.
```

### 5.2 Code Comments and DocStrings

- Use Google-style docstrings (readable and machine-parseable):

``` python
def fetch_user(user_id: int) -> User:
    """Fetch a user by ID.
    
    Args:
        user_id: The unique identifier for the user.
    
    Returns:
        A User object.
    
    Raises:
        ValueError: If user_id is invalid.
        UserNotFoundError: If the user does not exist.
    
    Example:
        >>> user = fetch_user(123)
        >>> print(user.name)
    """
    pass
```

- Use type hints instead of type documentation
- Comment why, not what (code should be self-explanatory).

### 5.3 API Documentation

- Use Pydantic with FastAPI for auto-generated OpenAPI docs
- For non-FastAPI services, use Sphinx with autodoc

### 6. Error Handling and Logging

- Create custom exceptions for your domain:

``` python
  class UserNotFoundError(Exception):
    """Raised when a user cannot be found."""
    pass

  class InvalidUserDataError(ValueError):
    """Raised when user data is invalid."""
    pass
```

- Catch specific exceptions; avoid bare except:
- Use context managers for resource cleanup:

``` python
  from contextlib import contextmanager

  @contextmanager
  def get_db_connection():
    conn = create_connection()
    try:
        yield conn
    finally:
        conn.close()
```

### 6.2 Structured Logging

- Use structlog or python-json-logger for structured logs:

``` python
 import logging
import json

logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

logger.info("user_created", extra={"user_id": 123, "email": "john@example.com"})
```

- Include context: request ID, user ID, trace ID for debugging

- Never log sensitive data (passwords, API keys, PII)

## 7. Performance and Optimization

### 7.1 Profiling

``` python
import cProfile
import pstats

profiler = cProfile.Profile()
profiler.enable()
# Code to profile
profiler.disable()
stats = pstats.Stats(profiler)
stats.sort_stats('cumulative').print_stats(10)
```

- Use memory_profiler for memory profiling:

``` python 
from memory_profiler import profile

@profile
def my_function():
    pass
```

### 7.2 Database Optimization

- Use SQLAlchemy with proper connection pooling

- Index frequently queried columns

- Avoid N+1 queries; use eager loading (joinedload, selectinload)

- Monitor slow queries

### 7.3 Async/Concurrency

- Use asyncio for I/O-bound operations

- Use multiprocessing for CPU-bound operations

- Use thread pools judiciously (GIL limitations)

## 8. Security Best Practices

### 8.1 Secrets Management
  
- Never hardcode secrets (API keys, database credentials, tokens)
- Use environment variables or secret managers:
  - AWS Secrets Manager / Parameter Store
  - Azure Key Vault
  - HashiCorp Vault
- Use python-dotenv only for local development:

``` python
from dotenv import load_dotenv
import os

load_dotenv()
db_password = os.getenv("DB_PASSWORD")
```

### 8.2 Input Validation

- Always validate and sanitize user input
- Use Pydantic for automatic validation
- Use parameterized queries to prevent SQL injection:

``` python
# Bad
query = f"SELECT * FROM users WHERE id = {user_id}"

# Good
from sqlalchemy import text
query = text("SELECT * FROM users WHERE id = :user_id")
db.execute(query, {"user_id": user_id})
```

## 9. Resources and Tools

- Essential Tools
  - Poetry: Dependency management
  - Black: Code formatting
  - Ruff: Fast linter
  - MyPy: Type checking
  - Pytest: Testing framework
  - Coverage.py: Code coverage
  
- Learning Resources
  - PEP 8 Style Guide {<https://pep8.org/>}
  - Real Python Best Practices {<https://realpython.com/>}
  - FastAPI Documentation {<https://fastapi.tiangolo.com/>}
  - Pytest Documentation {<https://docs.pytest.org/>}
  - Python Type Hints {<https://docs.python.org/3/library/typing.html>}
