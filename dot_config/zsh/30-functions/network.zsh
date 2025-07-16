# Network related functions

# Start an HTTP server from a directory, optionally specifying the port
function server() {
    local port="${1:-8000}";
    
    # Check if Python 3 is available
    if ! command -v python3 >/dev/null 2>&1; then
        echo "ERROR: Python 3 is required but not installed." >&2
        return 1
    fi
    
    sleep 1 && open "http://localhost:${port}/" &
    # Use Python 3's http.server module instead of deprecated Python 2 SimpleHTTPServer
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8
    python3 -c "
import http.server
import socketserver
import mimetypes

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def guess_type(self, path):
        mimetype, encoding = mimetypes.guess_type(path)
        if mimetype:
            return mimetype + ';charset=UTF-8'
        else:
            return 'text/plain;charset=UTF-8'

with socketserver.TCPServer(('', ${port}), CustomHTTPRequestHandler) as httpd:
    print(f'Serving HTTP on 0.0.0.0 port ${port} (http://0.0.0.0:${port}/) ...')
    httpd.serve_forever()
"
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
    if [ -z "${1}" ]; then
        echo "ERROR: No domain specified.";
        return 1;
    fi;

    local domain="${1}";
    echo "Testing ${domain}…";
    echo ""; # newline

    local tmp
    tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
        | openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

    if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
        local certText
        certText=$(echo "${tmp}" \
            | openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
            no_serial, no_sigdump, no_signame, no_validity, no_version");
        echo "Common Name:";
        echo ""; # newline
        echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
        echo ""; # newline
        echo "Subject Alternative Name(s):";
        echo ""; # newline
        echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
            | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
        return 0;
    else
        echo "ERROR: Certificate not found.";
        return 1;
    fi;
}

# Run `dig` and display the most useful info
function digga() {
    dig +nocmd "$1" any +multiline +noall +answer;
}

function whereami() {
    # Try wired connection first, if not found use wireless
    local private_ip
    private_ip=$(ipconfig getifaddr en1 || ipconfig getifaddr en0)
    
    # Get public IP using HTTPS and with timeout
    local public_ip
    public_ip=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null || echo "Failed to fetch")
    
    echo "Private IP: ${private_ip:-No private IP found}"
    echo "Public IP: ${public_ip:-No public IP found}"
} 