# HTTP ssl
Configuring our servers to much DNS records, we can use the same certificate for all of them. This is a good practice to
avoid the use of self-signed certificates, which are not trusted by browsers.
## [0. Install nginx web server](0-world_wide_web)
- Bash script must accept 2 arguments:
  - domain:
    - type: string 
    - what: domain name to audit 
    - mandatory: yes 
  - subdomain:
    - type: string 
    - what: specific subdomain to audit 
    - mandatory: no
- Output: <pre>The subdomain [SUB_DOMAIN] is a [RECORD_TYPE] record and points to [DESTINATION] </pre>
- When only the parameter domain is provided, display information for its subdomains www, lb-01, web-01 and web-02 - in 
this specific order
- When passing domain and subdomain parameters, display information for the specified subdomain 
- Ignore shellcheck case SC2086 
- Must use:
  - awk
  at least one Bash function 
- You do not need to handle edge cases such as:
  - Empty parameters 
  - Nonexistent domain names 
  - Nonexistent subdomains
