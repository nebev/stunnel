# stunnel Docker File

This is a simple stunnel Docker image, with full auditability. Suitable for LDAP Proxying.

There are stunnel images out there with millions of pulls, with no Github source and only a floating `latest` tag - when you're using stunnel for encryption and potentially handling usernames and passwords, it's important to be able to quickly and easily browse sources. I don't trust random people on the internet, and neither should you.

Mount your configuration file in the `/etc/stunnel` directory, along with whatever certificates you wish.

## Running

### Using Docker

```sh
docker run -itd --name ldaps\
  -p 636:636 \
  -c /path/to/stunnel.conf:/etc/stunnel/myconfig.conf \
  -v /path/to/server.key:/etc/stunnel/server.key:ro \
  -v /path/to/server.pem:/etc/stunnel/server.pem:ro \
  nebev/stunnel
```

### Using Docker-Compose

```
services:
  stunnel:
    image: nebev/stunnel
    container_name: ldaps
    ports:
      - "636:636"
    volumes:
      - ./stunnel.conf:/etc/stunnel/myconfig.conf:ro
      - ./server.key:/etc/stunnel/server.key:ro
      - ./server.pem:/etc/stunnel/server.pem:ro
    restart: unless-stopped
```

### Kubernetes

#### Config

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: stunnel-config
data:
  stunnel.conf: |
    [ldap]
    client = yes
    accept = 0.0.0.0:1636
    connect = ldap.google.com:636
    cert = /etc/stunnel/server.pem
    key = /etc/stunnel/server.key
---
apiVersion: v1
kind: Secret
metadata:
  name: stunnel-certificates
type: Opaque
data:
  server.key: <base64_encoded_server_key>
  server.pem: <base64_encoded_server_pem>
```

#### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stunnel
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stunnel
  template:
    metadata:
      labels:
        app: stunnel
    spec:
      containers:
      - name: stunnel
        image: nebev/stunnel
        ports:
        - containerPort: 1636
        volumeMounts:
        - name: config-volume
          mountPath: /etc/stunnel/myconfig.conf
          subPath: stunnel.conf
        - name: cert-volume
          mountPath: /etc/stunnel/server.key
          subPath: server.key
          readOnly: true
        - name: cert-volume
          mountPath: /etc/stunnel/server.pem
          subPath: server.pem
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: stunnel-config
      - name: cert-volume
        secret:
          secretName: stunnel-certificates
---
apiVersion: v1
kind: Service
metadata:
  name: stunnel
spec:
  selector:
    app: stunnel
  ports:
  - protocol: TCP
    port: 1636
    targetPort: 1636
  type: ClusterIP
```

## Sample stunnel configuration files

### Google LDAP

```
[ldap]
client = yes
accept = 0.0.0.0:1636
connect = ldap.google.com:636
cert = /etc/ssl/private/server.crt
key = /etc/ssl/private/server.key
```

