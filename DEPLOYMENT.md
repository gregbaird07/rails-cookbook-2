# Rails Cookbook 2 - Kamal Deployment Guide

## Prerequisites

Before deploying with Kamal, ensure you have:

1. **Server Setup**:
   - A Linux server (Ubuntu 20.04+ recommended)
   - Docker installed on the server
   - SSH access to the server
   - A domain name pointing to your server

2. **Docker Registry**:
   - Docker Hub account (or GitHub Container Registry, DigitalOcean Registry, etc.)
   - Registry access token/password

3. **Environment Variables**:
   - `KAMAL_REGISTRY_PASSWORD`: Your Docker registry password/token
   - Rails master key (automatically handled by `.kamal/secrets`)

## Deployment Steps

### 1. Configure Your Server
Update `config/deploy.yml` with your actual server details:
```yaml
servers:
  web:
    - YOUR_SERVER_IP  # Replace with your server's IP address

proxy:
  ssl: true
  host: your-domain.com  # Replace with your actual domain

registry:
  username: your-username  # Replace with your Docker Hub username

image: your-username/rails-cookbook-2  # Replace with your Docker Hub username
```

### 2. Set Environment Variables
```bash
# Set your Docker registry password
export KAMAL_REGISTRY_PASSWORD="your_docker_hub_token"
```

### 3. Initial Server Setup
```bash
# Install Docker and prepare the server
bin/kamal server bootstrap
```

### 4. Deploy Your Application
```bash
# Build and deploy the application
bin/kamal deploy
```

### 5. Useful Kamal Commands
```bash
# Check application status
bin/kamal app details

# View application logs
bin/kamal logs

# Open Rails console on server
bin/kamal console

# SSH into the server
bin/kamal shell

# Restart the application
bin/kamal app restart

# Update with new code
bin/kamal deploy

# Rollback to previous version
bin/kamal rollback [VERSION]
```

## Configuration Details

### Database
The app uses SQLite with persistent storage mounted at `/rails/storage`.

### SSL/HTTPS
Kamal will automatically set up Let's Encrypt SSL certificates for your domain.

### Environment Variables
All sensitive data is handled through `.kamal/secrets` file which pulls from:
- Environment variables
- Local files (like `config/master.key`)
- Password managers (optional)

## Troubleshooting

### Common Issues:
1. **Connection refused**: Check if Docker is running on your server
2. **Permission denied**: Ensure your SSH key is added to the server
3. **Domain not resolving**: Verify DNS settings point to your server
4. **SSL issues**: Make sure your domain is properly configured

### Debug Commands:
```bash
# Check server connectivity
bin/kamal server bootstrap --dry-run

# View detailed deployment logs
bin/kamal deploy --verbose

# Check running containers
bin/kamal app exec "docker ps"
```

## Security Notes

- Never commit real passwords to git
- Use environment variables or password managers for secrets
- Keep your server updated with security patches
- Consider using a firewall to restrict access to necessary ports only

## Next Steps

1. Replace placeholder values in `config/deploy.yml`
2. Set up your server and Docker registry
3. Run the deployment commands
4. Monitor your application with `bin/kamal logs`

Happy deploying! 🚀
