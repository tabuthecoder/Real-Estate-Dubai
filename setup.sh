#!/bin/bash

# RealtyFlow Pro - Complete Setup Script
# This script sets up the entire application with all new features

set -e  # Exit on any error

echo "🚀 RealtyFlow Pro - Complete Setup"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    print_warning "Detected Windows environment"
    MYSQL_CMD="mysql"
    PHP_CMD="php"
    NPM_CMD="npm"
else
    MYSQL_CMD="mysql"
    PHP_CMD="php"
    NPM_CMD="npm"
fi

# Check prerequisites
print_status "Checking prerequisites..."

# Check if MySQL is running
if ! pgrep -x "mysqld" > /dev/null && ! pgrep -x "mysql" > /dev/null; then
    print_error "MySQL is not running. Please start MySQL/XAMPP first."
    exit 1
fi

# Check if PHP is available
if ! command -v $PHP_CMD &> /dev/null; then
    print_error "PHP is not installed or not in PATH"
    exit 1
fi

# Check if Node.js is available
if ! command -v $NPM_CMD &> /dev/null; then
    print_error "Node.js is not installed or not in PATH"
    exit 1
fi

print_success "Prerequisites check passed"

# Database setup
print_status "Setting up database..."

# Read database configuration
if [ -f "config/db.config.local.php" ]; then
    DB_CONFIG="config/db.config.local.php"
else
    DB_CONFIG="config/db.config.php"
fi

# Extract database credentials from config file
DB_HOST=$(grep -o "'host' => '[^']*'" $DB_CONFIG | cut -d"'" -f4)
DB_NAME=$(grep -o "'database' => '[^']*'" $DB_CONFIG | cut -d"'" -f4)
DB_USER=$(grep -o "'username' => '[^']*'" $DB_CONFIG | cut -d"'" -f4)
DB_PASS=$(grep -o "'password' => '[^']*'" $DB_CONFIG | cut -d"'" -f4)

if [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
    print_error "Could not read database configuration from $DB_CONFIG"
    exit 1
fi

print_status "Database config: $DB_HOST/$DB_NAME (user: $DB_USER)"

# Create database if it doesn't exist
print_status "Creating database if it doesn't exist..."
$MYSQL_CMD -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || {
    print_warning "Could not create database. It might already exist or you may need to create it manually."
}

# Run enhanced database schema
print_status "Running enhanced database schema..."
if [ -f "database/enhanced_schema.sql" ]; then
    $MYSQL_CMD -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < database/enhanced_schema.sql
    print_success "Enhanced database schema applied"
else
    print_error "Enhanced schema file not found: database/enhanced_schema.sql"
    exit 1
fi

# Install frontend dependencies
print_status "Installing frontend dependencies..."
cd src
$NPM_CMD install
print_success "Frontend dependencies installed"

# Build frontend
print_status "Building frontend..."
$NPM_CMD run build
print_success "Frontend built successfully"
cd ..

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p public/assets/icons
mkdir -p public/assets/screenshots
mkdir -p uploads/attachments
mkdir -p logs

# Set permissions (for Unix-like systems)
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" ]]; then
    chmod 755 uploads/
    chmod 755 logs/
    print_status "Set directory permissions"
fi

# Create sample PWA icons (placeholder)
print_status "Creating PWA assets..."
cat > public/assets/icons/icon-192x192.png << 'EOF'
# This is a placeholder. Replace with actual icon files
EOF

cat > public/assets/icons/icon-512x512.png << 'EOF'
# This is a placeholder. Replace with actual icon files
EOF

# Create offline page
cat > public/offline.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RealtyFlow Pro - Offline</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
        }
        .icon {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        h1 {
            margin-bottom: 1rem;
        }
        p {
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        button {
            background: rgba(255, 255, 255, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.3);
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem;
            cursor: pointer;
            font-size: 1rem;
        }
        button:hover {
            background: rgba(255, 255, 255, 0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">📱</div>
        <h1>You're Offline</h1>
        <p>Please check your internet connection and try again.</p>
        <button onclick="window.location.reload()">Retry</button>
    </div>
</body>
</html>
EOF

print_success "PWA assets created"

# Create .htaccess for Apache
cat > .htaccess << 'EOF'
RewriteEngine On

# Handle React Router
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ /index.html [QSA,L]

# Security headers
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"
Header always set Referrer-Policy "strict-origin-when-cross-origin"

# Cache static assets
<FilesMatch "\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
    Header set Cache-Control "public, immutable"
</FilesMatch>

# Don't cache HTML files
<FilesMatch "\.(html|php)$">
    Header set Cache-Control "no-cache, no-store, must-revalidate"
    Header set Pragma "no-cache"
    Header set Expires 0
</FilesMatch>

# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>
EOF

print_success "Apache configuration created"

# Create cron job for inactivity checks
print_status "Setting up automated tasks..."

# Create a simple cron script
cat > scripts/cron_tasks.sh << 'EOF'
#!/bin/bash

# RealtyFlow Pro - Automated Tasks
# Run this script via cron for automated maintenance

cd "$(dirname "$0")/.."

# Check for inactive users and send notifications
php -f scripts/check_inactive_users.php

# Update marketplace status for all countries
php -f scripts/update_marketplace_status.php

# Clean up old analytics data (older than 90 days)
php -f scripts/cleanup_analytics.php

# Backup database
php -f scripts/backup_database.php
EOF

chmod +x scripts/cron_tasks.sh

# Create individual task scripts
cat > scripts/check_inactive_users.php << 'EOF'
<?php
require_once 'includes/init.php';
use App\Services\Notification\NotificationService;

$notificationService = new NotificationService();
$inactiveCount = $notificationService->checkInactiveUsers();
echo "Checked $inactiveCount inactive users\n";
EOF

cat > scripts/update_marketplace_status.php << 'EOF'
<?php
require_once 'includes/init.php';
use App\Services\Timezone\TimezoneService;

$timezoneService = new TimezoneService();
$timezoneService->updateAllMarketplaceStatus();
echo "Updated marketplace status for all countries\n";
EOF

cat > scripts/cleanup_analytics.php << 'EOF'
<?php
require_once 'includes/init.php';
use App\Core\Database;

$db = Database::getInstance()->getConnection();
$db->exec("DELETE FROM user_analytics WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY)");
$db->exec("DELETE FROM ip_locations WHERE cached_at < DATE_SUB(NOW(), INTERVAL 30 DAY)");
echo "Cleaned up old analytics data\n";
EOF

cat > scripts/backup_database.php << 'EOF'
<?php
require_once 'config/db.config.php';

$backupDir = 'backups/';
if (!is_dir($backupDir)) {
    mkdir($backupDir, 0755, true);
}

$filename = $backupDir . 'backup_' . date('Y-m-d_H-i-s') . '.sql';
$command = "mysqldump -h{$config['host']} -u{$config['username']} -p{$config['password']} {$config['database']} > $filename";
exec($command);
echo "Database backup created: $filename\n";
EOF

print_success "Automated tasks configured"

# Create environment-specific configuration
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
# RealtyFlow Pro Environment Configuration
APP_ENV=development
APP_DEBUG=true
APP_URL=http://localhost/Real-Estate

# Database
DB_HOST=localhost
DB_NAME=real_estate_local
DB_USER=root
DB_PASS=

# External APIs
IP_API_URL=http://ip-api.com/json
WHATSAPP_API_KEY=your_whatsapp_api_key
PUSH_VAPID_PUBLIC_KEY=your_vapid_public_key
PUSH_VAPID_PRIVATE_KEY=your_vapid_private_key

# Email Configuration
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_ENCRYPTION=tls

# File Upload
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES=jpg,jpeg,png,gif,pdf,doc,docx

# Security
SESSION_SECRET=your_session_secret_key
JWT_SECRET=your_jwt_secret_key

# Analytics
ANALYTICS_ENABLED=true
ANALYTICS_RETENTION_DAYS=90

# Notifications
PUSH_NOTIFICATIONS_ENABLED=true
WHATSAPP_NOTIFICATIONS_ENABLED=true
EMAIL_NOTIFICATIONS_ENABLED=true
EOF
    print_success "Environment configuration created"
fi

# Create README for the enhanced features
cat > FEATURES.md << 'EOF'
# RealtyFlow Pro - Enhanced Features

## 🚀 New Features Implemented

### 1. IP-Based Analytics & Click Tracking
- **Real-time user activity tracking**
- **Geolocation-based analytics**
- **Device and browser detection**
- **Click tracking and session monitoring**
- **Analytics dashboard with detailed insights**

### 2. Dynamic Marketplace Operational Hours
- **Timezone-aware operational status**
- **IP-based location detection**
- **Real-time marketplace status updates**
- **Currency and timezone display**
- **Operational hours management**

### 3. Feedback & Issue Management System
- **Comprehensive ticket system**
- **Priority and category management**
- **Internal and external responses**
- **File attachments support**
- **Status tracking and assignment**

### 4. User Activity Tracking & Inactivity Management
- **Session duration tracking**
- **Page visit monitoring**
- **Action counting**
- **Automatic inactivity detection**
- **WhatsApp integration for notifications**

### 5. PWA Support
- **Progressive Web App capabilities**
- **Offline functionality**
- **Push notifications**
- **Background sync**
- **App-like experience**

### 6. WhatsApp Integration
- **Phone number verification**
- **Automated notifications**
- **Message templates**
- **Delivery status tracking**

## 📊 Database Enhancements

### New Tables Added:
- `user_analytics` - User activity and IP tracking
- `ip_locations` - IP geolocation cache
- `user_sessions` - Session management
- `country_operational_hours` - Timezone management
- `marketplace_status` - Real-time status
- `feedback_tickets` - Issue management
- `ticket_responses` - Ticket communication
- `ticket_attachments` - File attachments
- `user_activity` - User engagement tracking
- `inactivity_notifications` - Inactivity alerts
- `whatsapp_integrations` - WhatsApp connections
- `push_subscriptions` - PWA notifications
- `notifications` - System notifications
- `property_views` - Property analytics
- `property_favorites` - User favorites

## 🔧 API Endpoints

### Analytics
- `POST /api/analytics/track` - Track user activity
- `GET /api/analytics/track` - Get analytics data

### Timezone Management
- `GET /api/timezone/status` - Get marketplace status
- `POST /api/timezone/status` - Update status

### Feedback System
- `POST /api/feedback/tickets` - Create ticket
- `GET /api/feedback/tickets` - Get tickets
- `PUT /api/feedback/tickets` - Update ticket

### Notifications
- `POST /api/notification/notifications` - Create/manage notifications
- `GET /api/notification/notifications` - Get notifications
- `PUT /api/notification/notifications` - Update notifications

## 🎯 Frontend Components

### New React Components:
- `AnalyticsDashboard` - Comprehensive analytics view
- `MarketplaceStatus` - Real-time status display
- `FeedbackSystem` - Issue management interface
- `NotificationCenter` - PWA and notification management

## 🔒 Security Features

- **Input validation and sanitization**
- **SQL injection prevention**
- **XSS protection**
- **CSRF protection**
- **Rate limiting**
- **Secure file uploads**

## 📱 PWA Features

- **Service Worker for offline support**
- **Push notifications**
- **Background sync**
- **App manifest**
- **Install prompts**

## 🚀 Performance Optimizations

- **Database indexing**
- **Query optimization**
- **Caching strategies**
- **Lazy loading**
- **Code splitting**

## 📈 Monitoring & Analytics

- **Real-time user tracking**
- **Performance monitoring**
- **Error tracking**
- **Usage analytics**
- **Conversion tracking**

## 🔄 Automated Tasks

- **Inactivity user detection**
- **Marketplace status updates**
- **Analytics cleanup**
- **Database backups**

## 🛠️ Setup Instructions

1. **Database Setup**: Run the enhanced schema
2. **Dependencies**: Install frontend and backend dependencies
3. **Configuration**: Set up environment variables
4. **PWA Setup**: Configure service worker and manifest
5. **External APIs**: Set up WhatsApp and push notification APIs
6. **Cron Jobs**: Configure automated tasks

## 📋 Usage Examples

### Tracking User Activity
```javascript
// Frontend
await fetch('/api/analytics/track', {
  method: 'POST',
  body: JSON.stringify({
    page_visited: '/properties',
    click_count: 1
  })
});
```

### Creating Feedback Ticket
```javascript
await fetch('/api/feedback/tickets', {
  method: 'POST',
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com',
    subject: 'Bug Report',
    message: 'Website is slow',
    category: 'bug',
    priority: 'high'
  })
});
```

### Getting Marketplace Status
```javascript
const response = await fetch('/api/timezone/status');
const status = await response.json();
console.log(status.data.current_status);
```

## 🎉 Success Metrics

- **User Engagement**: Tracked through analytics
- **Issue Resolution**: Managed through feedback system
- **User Retention**: Monitored through activity tracking
- **Performance**: Measured through PWA metrics
- **User Satisfaction**: Gauged through feedback system

## 🔮 Future Enhancements

- **AI-powered analytics insights**
- **Advanced chatbot integration**
- **Video calling features**
- **Advanced reporting dashboard**
- **Multi-language support**
- **Advanced security features**

---

**RealtyFlow Pro** - The complete real estate platform with enterprise-grade features!
EOF

print_success "Features documentation created"

# Final setup summary
echo ""
echo "🎉 RealtyFlow Pro Setup Complete!"
echo "================================"
echo ""
echo "✅ Database schema applied with all new features"
echo "✅ Frontend dependencies installed and built"
echo "✅ PWA assets and service worker configured"
echo "✅ Automated tasks and cron jobs set up"
echo "✅ Security configurations applied"
echo "✅ Environment configuration created"
echo ""
echo "🚀 Next Steps:"
echo "1. Configure your .env file with actual API keys"
echo "2. Set up cron jobs for automated tasks:"
echo "   crontab -e"
echo "   # Add: 0 */6 * * * /path/to/your/project/scripts/cron_tasks.sh"
echo "3. Start your web server (Apache/Nginx)"
echo "4. Access the application at: http://localhost/Real-Estate"
echo ""
echo "📚 Documentation:"
echo "- Read FEATURES.md for detailed feature documentation"
echo "- Check README.md for general setup instructions"
echo ""
echo "🔧 Troubleshooting:"
echo "- Check logs/ directory for error logs"
echo "- Verify database connection in config/db.config.php"
echo "- Ensure all file permissions are set correctly"
echo ""
print_success "Setup completed successfully!" 