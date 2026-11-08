"""Serves the recording folder (the MP4 and the logs) on $PORT."""
import http.server, os, sys

os.chdir(sys.argv[1])
port = int(os.environ.get("PORT", "8080"))
http.server.ThreadingHTTPServer(("0.0.0.0", port), http.server.SimpleHTTPRequestHandler).serve_forever()
