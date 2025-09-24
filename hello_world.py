from http.server import BaseHTTPRequestHandler, HTTPServer

class HelloHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Send response status code
        self.send_response(200)

        # Send headers
        self.send_header('Content-type', 'text/plain')
        self.end_headers()

        # Send the response content
        self.wfile.write(b'Hello, World!')

if __name__ == '__main__':
    server_address = ('localhost', 4232)
    httpd = HTTPServer(server_address, HelloHandler)
    print('Serving on http://localhost:4232')
    httpd.serve_forever()
