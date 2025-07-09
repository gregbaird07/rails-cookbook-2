# Kamal Deployment Checklist for Rails Cookbook 2

## ✅ Pre-Deployment Setup

### 1. Server Requirements
- [ ] Linux server (Ubuntu 20.04+ recommended) with Docker installed
- [ ] SSH access to your server with public key authentication
- [ ] Domain name configured to point to your server IP
- [ ] Server has at least 1GB RAM and 20GB storage

### 2. Update Configuration
Edit `config/deploy.yml` and replace:
- [ ] `YOUR_SERVER_IP` → your actual server IP address
- [ ] `your-domain.com` → your actual domain name  
- [ ] `your-username` → your Docker Hub username

### 3. Set Environment Variables
```bash
export KAMAL_REGISTRY_PASSWORD="your_docker_hub_access_token"
```

## 🚀 Deployment Commands

### Initial Deployment
```bash
# 1. Bootstrap server (install Docker, setup firewall)
bin/kamal server bootstrap

# 2. Deploy application for the first time
bin/kamal deploy

# 3. Check deployment status
bin/kamal app details
```

### Subsequent Deployments
```bash
# Deploy new code changes
bin/kamal deploy

# Quick restart without rebuilding
bin/kamal app restart
```

## 🔧 Management Commands

### Monitoring
```bash
# View live logs
bin/kamal logs

# Check app status
bin/kamal app details

# View all running containers
bin/kamal app exec "docker ps"
```

### Debugging
```bash
# Open Rails console on server
bin/kamal console

# SSH into the container
bin/kamal shell

# Open database console
bin/kamal dbc
```

### Rollback
```bash
# List previous versions
bin/kamal app versions

# Rollback to previous version
bin/kamal rollback

# Rollback to specific version
bin/kamal rollback [VERSION_ID]
```

## 📋 Post-Deployment Checklist

- [ ] Application is accessible at your domain
- [ ] SSL certificate is working (https://)
- [ ] User registration works
- [ ] Recipe creation/editing works
- [ ] Database is persisting data
- [ ] Logs show no errors: `bin/kamal logs`

## 🛠️ Troubleshooting

### Common Issues:

**"Connection refused"**
```bash
# Check if Docker is running on server
bin/kamal server bootstrap
```

**"Permission denied"**
```bash
# Ensure SSH key is added to server
ssh-copy-id user@YOUR_SERVER_IP
```

**"Registry authentication failed"**
```bash
# Check your Docker Hub token
echo $KAMAL_REGISTRY_PASSWORD
```

**"Domain not resolving"**
- Verify DNS A record points to your server IP
- Wait for DNS propagation (up to 24 hours)

**"SSL certificate issues"**
- Ensure domain is accessible via HTTP first
- Let's Encrypt needs port 80 and 443 open

### Debug Commands:
```bash
# Test configuration without deploying
bin/kamal config

# Dry run deployment
bin/kamal deploy --dry-run

# Verbose output
bin/kamal deploy --verbose
```

## 🔐 Security Notes

- Use SSH keys instead of passwords
- Keep server updated: `sudo apt update && sudo apt upgrade`
- Configure firewall to only allow necessary ports (22, 80, 443)
- Use strong passwords for Docker registry
- Regularly backup your application data

## 📊 Monitoring

### Health Checks
```bash
# Check if app is responding
curl -I https://your-domain.com

# Monitor resource usage
bin/kamal app exec "top"
bin/kamal app exec "df -h"
```

### Log Management
```bash
# Follow logs in real-time
bin/kamal logs -f

# View specific number of log lines
bin/kamal logs --lines 100
```

Ready to deploy? Start with updating your `config/deploy.yml` file! 🎯
