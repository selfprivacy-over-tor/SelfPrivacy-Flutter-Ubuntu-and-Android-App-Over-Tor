from flask import Flask, request, jsonify
from ariadne import QueryType, MutationType, gql, make_executable_schema
from ariadne.explorer import ExplorerGraphiQL
from ariadne.wsgi import GraphQL

# Define the GraphQL schema with the required 'api' query
type_defs = gql("""
    type Query {
        api: Api!
        hello(name: String = "World"): String!
    }

    type Api {
        version: String!
    }

    type Mutation {
        createMessage(content: String!): String!
    }
""")

# Define resolvers
query = QueryType()
mutation = MutationType()

@query.field("hello")
def resolve_hello(_, info, name="World"):
    return f"Hello, {name}!"

@query.field("api")
def resolve_api(_, info):
    # Return an object with a 'version' field
    return {"version": "1.0.0"}  # Replace with your actual API version

@mutation.field("createMessage")
def resolve_create_message(_, info, content):
    return f"Message created: {content}"

# Create executable schema
schema = make_executable_schema(type_defs, query, mutation)

# Create Flask app
app = Flask(__name__)

# Initialize GraphQL server
graphql_server = GraphQL(schema, debug=True)

# Initialize GraphiQL explorer
explorer = ExplorerGraphiQL(title="GraphQL Playground")

# GraphQL endpoint for GET (GraphiQL interface)
@app.route('/graphql', methods=['GET'])
def graphql_playground():
    return explorer.html(None), 200

# GraphQL endpoint for POST (API queries)
@app.route('/graphql', methods=['POST'])
def graphql_endpoint():
    data = request.get_json()
    success, result = graphql_server.execute_query(request.environ, data)
    status_code = 200 if success else 400
    return jsonify(result), status_code

if __name__ == '__main__':
    # Run Flask with HTTPS using the self-signed certificate and key
    app.run(host='0.0.0.0', port=5555, debug=True, ssl_context=('cert.pem', 'key.pem'))