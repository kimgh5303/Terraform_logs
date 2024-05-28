#!/bin/bash
# Amazon Linux 2 userdata script for setting up Nginx and integrating with Kinesis Data Streams

# Update packages
sudo yum update -y

# Install Nginx
sudo yum install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Fetch EC2 metadata using the token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
RZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
IID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
LIP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

# Create HTML file with JavaScript to handle button clicks
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Simple Shopping Site with Click Tracking</title>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('buyButton').addEventListener('click', function() {
            fetch('/log-click', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    eventType: 'ButtonClick',
                    timestamp: new Date().toISOString(),
                    buttonId: 'buyButton'
                })
            })
            .then(response => {
                if (response.ok) {
                    console.log("success");
                } else {
                    console.error("fail");
                }
            })
            .catch(error => {
                console.error("fail:", error);
            });
        });
    });
    </script>
</head>
<body>
<h1>Welcome to Our Simple Shop</h1>
<button id="buyButton">Buy Now</button>
<h1>RegionAz($RZAZ) : Instance ID($IID) : Private IP($LIP) : Web Server</h1>
</body>
</html>
EOF

# Set up reverse proxy for /log-click to handle POST requests
cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
    location /log-click {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Restart Nginx to apply changes
sudo systemctl restart nginx

# Install Node.js and NPM
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs

# Create a simple Node.js server to log data to a file
mkdir -p /home/ec2-user/app
cat <<EOF > /home/ec2-user/app/server.js
const express = require('express');
const fs = require('fs');
const app = express();
app.use(express.json());

app.post('/log-click', (req, res) => {
    const logEntry = \`\$${JSON.stringify(req.body)}\n\`;
    fs.appendFile('/var/log/click_log.txt', logEntry, err => {
        if (err) {
            console.error('Error writing to log file:', err);
            res.status(500).send('Internal Server Error');
            return;
        }
        res.status(200).send('Click logged');
    });
});

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
EOF

# Start the Node.js server
cd /home/ec2-user/app
npm init -y
npm install express
nohup node server.js > /home/ec2-user/app/server.log 2>&1 &

# Install and configure Amazon Kinesis Agent
sudo yum install -y aws-kinesis-agent

cat <<EOF > /etc/aws-kinesis/agent.json
{
    "cloudwatch.emitMetrics": true,
    "kinesis.endpoint": "kinesis.ap-northeast-2.amazonaws.com",
    "flows": [
        {
            "filePattern": "/var/log/click_log.txt",
            "kinesisStream": "kgh-kinesis-datastreams",
            "partitionKeyOption": "RANDOM"
        }
    ]
}
EOF

# Start the Kinesis Agent
sudo service aws-kinesis-agent start
