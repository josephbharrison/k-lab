import os
from flask import jsonify, make_response, request, redirect
from flask_cors import CORS
from flask_openapi3 import OpenAPI, Info, Tag, Server
from flask_caching import Cache
from pydantic import BaseModel, Field
from typing import Optional
from http import HTTPStatus
from functools import wraps
from tokens import TOKENS

# Environment variables
app_host = os.getenv('APP_HOST', '0.0.0.0')
app_port = int(os.getenv('APP_PORT', 5003))

# API information
info = Info(title='Book API', version='1.0.0')
servers = [
    ## Local Server
    Server(url=f"http://{app_host}:{app_port}"),

    ## External Servers (Gateways/Proxy/Ingress)
    # Server(url=f"https://myapp.myserver.com:8443"),
]

# Create Flask app with OpenAPI
app = OpenAPI(__name__, info=info, servers=servers)
CORS(app, origins='*', methods=['GET', 'HEAD', 'OPTIONS'], max_age=3600, allow_headers='*')

# Cache configuration
app.config['CACHE_TYPE'] = 'simple'
app.config['CACHE_DEFAULT_TIMEOUT'] = 3600
cache = Cache(app)

resource_tag = Tag(name='Book', description='Operations related to book details')

# Request and Response Models
class BookSchema(BaseModel):
    isbn: str
    title: str
    author: str
    publication_year: int

class ErrorResponse(BaseModel):
    error: str

class ISBNPath(BaseModel):
    isbn: str = Field(None, description="International Standard Book Number")

class ISBNYearPath(ISBNPath):
    year: Optional[int] = Field(None, description="Publication year")

# API Key validation
def require_api_key(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if match_api_keys(request.headers.get('X-API-Key')):
            return f(*args, **kwargs)
        else:
            return make_response(jsonify({'error': 'Unauthorized'}), 401)
    return decorated

@app.get('/', strict_slashes=False)
def index():
    return redirect("https://example.com/documentation", code=302)

@app.get(
    '/books/<string:isbn>',
    tags=[resource_tag],
    operation_id='getBookDetails',
    summary="Retrieve details for a given book by ISBN",
    responses={
        HTTPStatus.OK: {"description": "Book details for the given ISBN", "content": {"application/json": {"schema": {"type": "array", "items": BookSchema.schema()}}}},
        HTTPStatus.UNAUTHORIZED: {"description": "Unauthorized", "content": {"application/json": {"schema": ErrorResponse.schema()}}},
        HTTPStatus.NOT_FOUND: {"description": "Not Found", "content": {"application/json": {"schema": ErrorResponse.schema()}}}
    }
)
@require_api_key
@cache.memoize()
def get_book_details(isbn: str):
    # Simulate fetching book details
    book_details = [{'isbn': isbn, 'title': 'Sample Book', 'author': 'Author Name', 'publication_year': 2020}]
    return jsonify(book_details)

@app.errorhandler(HTTPStatus.NOT_FOUND)
def handle_not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

@app.errorhandler(HTTPStatus.UNAUTHORIZED)
def handle_unauthorized(error):
    return make_response(jsonify({'error': 'Unauthorized'}), 401)

@app.errorhandler(HTTPStatus.INTERNAL_SERVER_ERROR)
def handle_internal_server_error(error):
    return make_response(jsonify({'error': 'Internal server error'}), 500)

def match_api_keys(key):
    return key in TOKENS

if __name__ == '__main__':
    app.run(host=app_host, port=app_port, debug=True)
