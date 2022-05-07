#!/usr/bin/env python3
#
# This little python programm will crawl the shoreline statistics when requested on its own rest-endpoint
# and return the statistics in a prometheus compatible format.
# The data can be requested at `<host>:7979`
#

import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
import socketserver
import json
import cgi
import socket
import textwrap

class Server(SimpleHTTPRequestHandler):
        
    def do_GET(self):

        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.connect((PIXELFLUT_HOST, PIXELFLUT_STATISTICS_PORT))
                
                data = s.recv(1024)
                s.close()

            statistics = json.loads(data)

            prometheus_content = textwrap.dedent("""
                # HELP shoreline_statistics_traefik_bytes Traffic in bytes
                # TYPE shoreline_statistics_traefik_bytes counter
                shoreline_statistics_traefik_bytes{host="%s"} %d
                # HELP shoreline_statistics_traefik_pixel Traffic in pixels
                # TYPE shoreline_statistics_traefik_pixel counter
                shoreline_statistics_traefik_pixel{host="%s"} %d
                # HELP shoreline_statistics_throughput_bytes Throughput in bytes
                # TYPE shoreline_statistics_throughput_bytes gauge
                shoreline_statistics_throughput_bytes{host="%s"} %d
                # HELP shoreline_statistics_throughput_pixels Throughput in pixels
                # TYPE shoreline_statistics_throughput_pixels gauge
                shoreline_statistics_throughput_pixels{host="%s"} %d
                # HELP shoreline_statistics_connections Connection count
                # TYPE shoreline_statistics_connections gauge
                shoreline_statistics_connections{host="%s"} %d
                # HELP shoreline_statistics_fps Current frames per second
                # TYPE shoreline_statistics_fps gauge
                shoreline_statistics_fps{host="%s"} %d
                """ % (
                    PIXELFLUT_HOST, statistics['traffic']['bytes'],
                    PIXELFLUT_HOST, statistics['traffic']['pixels'],
                    PIXELFLUT_HOST, statistics['throughput']['bytes'],
                    PIXELFLUT_HOST, statistics['throughput']['pixels'],
                    PIXELFLUT_HOST, statistics['connections'],
                    PIXELFLUT_HOST, statistics['fps']
                    )
            )

            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(bytes(prometheus_content, "UTF-8"))
        except:
            print("Cant crawl from %s at port %d" % (PIXELFLUT_HOST, PIXELFLUT_STATISTICS_PORT))
            self.send_response(404, "%s:%d does not respond or does not have the correct format!" % (PIXELFLUT_HOST, PIXELFLUT_STATISTICS_PORT))
            self.end_headers()


def run():
    port = 7979
    httpd = HTTPServer(('', port), Server) 
    print('Starting prometheus endpoint on port %d...' % port)
    httpd.serve_forever()


if __name__ == "__main__":

    if (len(sys.argv) != 3):
        print("Must have 2 arguments: Pixelflut address to crawl, Pixelflut port to crawl")
        sys.exit(-1)

    PIXELFLUT_HOST = sys.argv[1]
    PIXELFLUT_STATISTICS_PORT = int(sys.argv[2])

    run()
