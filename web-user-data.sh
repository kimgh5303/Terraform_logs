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
RZAZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
IID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
LIP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

# Create HTML file with JavaScript to handle button clicks
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>

<head>
    <title>Simple Shopping Site with Click Tracking</title>
    <script>
    function generateRandomString(length) {
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        return result;
    }

    function getFormattedTimestamp() {
        var now = new Date();
        var localTime = new Date(now.getTime());

        var year = localTime.getFullYear();
        var month = localTime.getMonth() + 1;
        var day = localTime.getDate();
        var hour = localTime.getHours();
        var minute = localTime.getMinutes();
        var second = localTime.getSeconds();
        
        return `$${year}.$${month}.$${day}.$${hour}:$${minute}:$${second}`;
    }

    function generateRandomIP() {
        return `$${Math.floor(Math.random() * 256)}.$${Math.floor(Math.random() * 256)}.$${Math.floor(Math.random() * 256)}.$${Math.floor(Math.random() * 256)}`;
    }

    const sessionIds = Array.from({length: 10}, () => generateRandomString(10));
    const userIps = Array.from({length: 10}, () => generateRandomIP());
    
    /*
    const pageUrls = [
    '/', '/electronics', '/product/', '/cart', '/checkout', '/login', '/register', '/search?q=keyword', '/support', '/promotions'
    ];
    const pageCategories = ['mens_clothing', 'womens_clothing', 'accessories', 'outerwear', footwear];
    const durations = Array.from({length: 10}, () => Math.floor(Math.random() * 5000));
    const actionsCounts = Array.from({length: 10}, () => Math.floor(Math.random() * 100));
    */

    document.addEventListener('DOMContentLoaded', function() {
        const button = document.getElementById('buyButton');
        button.addEventListener('click', function() {
            // 각 필드별로 독립적인 무작위 인덱스를 생성
            const sessionIdIndex = Math.floor(Math.random() * sessionIds.length);
            const userIpIndex = Math.floor(Math.random() * userIps.length);
            /*
            const pageUrlIndex = Math.floor(Math.random() * pageUrls.length);
            const pageCategoryIndex = Math.floor(Math.random() * pageCategories.length);
            const durationIndex = Math.floor(Math.random() * durations.length);
            const actionsCountIndex = Math.floor(Math.random() * actionsCounts.length);
            */

            fetch('/log-click', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    eventType: 'ButtonClick',
                    timestamp: getFormattedTimestamp(),
                    sessionId: sessionIds[sessionIdIndex],
                    ip: userIps[userIpIndex],
                    /*
                    pageUrl: pageUrls[pageUrlIndex],
                    pageCategory: pageCategories[pageCategoryIndex],
                    duration: durations[durationIndex],
                    actionsCount: actionsCounts[actionsCountIndex]
                    */
                    })
            })
            .then(response => {
                if (response.ok) {
                    console.log("Event logged successfully");
                } else {
                    console.error("Failed to log event");
                }
            })
            .catch(error => {
                console.error("Error logging event:", error);
            });
        });
    });
    </script>
</head>

<body>
<h1>Welcome to Our Simple Shop</h1>
<h1>RegionAz($RZAZ) : Instance ID($IID) : Private IP($LIP) : Web Server</h1>
<button id="buyButton">Buy Now</button>
</body>
</html>
EOF

#--------------------------------------------------------------------------------------------------
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
