# Back-End

FastAPI application serving as the back-end service.

## Installation

Requires Python 3.14+ and [uv](https://docs.astral.sh/uv/).

```bash
cd back-end
uv sync
```

## Development

Start the development server with auto-reload:

```bash
uv run uvicorn main:app --reload
```

The server runs at `http://127.0.0.1:8000` by default.

## API Endpoints

| Method | Path      | Description              |
|--------|-----------|--------------------------|
| GET    | `/health` | Returns application status |

## API Documentation

Once the server is running, interactive docs are available at:

- Swagger UI: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`

## Dependencies

- [FastAPI](https://fastapi.tiangolo.com/) - Web framework
- [Uvicorn](https://www.uvicorn.org/) - ASGI server
