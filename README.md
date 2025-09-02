# RealtyFlow Pro

> **Prompt:**
> RealtyFlow Pro is a full-stack real estate marketing platform connecting property developers, agents, influencers, and clients. It features multi-role dashboards, campaign management, analytics, KYC, feedback, notifications, and PWA support. Designed for both local and global markets, it enables seamless collaboration, property promotion, and lead management with robust security and a modern UI.

---

## 🏗️ Project Overview

RealtyFlow Pro is a comprehensive web application for real estate professionals, enabling influencer-driven marketing, property management, and seamless collaboration between admins, builders, agents, influencers, and clients. The platform supports campaign workflows, analytics, feedback, KYC, notifications, and is PWA-ready for offline and mobile use.

## ✨ Features
- Multi-role authentication (Admin, Agent, Builder, Client, Influencer)
- Country/marketplace selection and timezone-aware dashboards
- Campaign management and property-deal association
- Analytics, user activity, and feedback system
- KYC document upload and verification
- Notification center (in-app, WhatsApp, inactivity alerts)
- PWA support (offline fallback, manifest, service worker)
- Admin tools for API management, bulk messaging, and batch uploads

## 🛠️ Tech Stack
- **Frontend:** React 18, TypeScript, Vite, Tailwind CSS, React Router v6
- **Backend:** PHP 8+, MySQL/MariaDB, PDO, Apache/Nginx
- **Dev Tools:** Node.js, npm, PostCSS, TypeScript Compiler

## 📁 File Tree
<details>
<summary>Click to expand full project file tree</summary>

```
Folder PATH listing
Volume serial number is 268D-8045
C:.
│   .gitignore
│   index.html
│   LICENSE
│   log_file.txt
│   package-lock.json
│   package.json
│   postcss.config.js
│   README.md
│   setup.sh
│   tailwind.config.js
│   tsconfig.json
│   tsconfig.node.json
│   vite.config.ts
│   
├───.git
│   ... (git internals omitted for brevity)
├───api
│   ├───admin
│   │       dashboard.php
│   │       users.php
│   │   ├───agent
│   │   │       dashboard.php
│   │   │   ├───analytics
│   │   │   │       activity.php
│   │   │   │       track.php
│   │   │   │   └───timezone
│   │   │   │           status.php
│   │   │   └───auth
│   │   │           kyc.php
│   │   │           login.php
│   │   │           register.php
│   │   │   ├───campaigns
│   │   │   │       assign_property.php
│   │   │   │       create.php
│   │   │   │       list.php
│   │   │   │       track.php
│   │   │   └───countries
│   │   │           list.php
│   │   │   ├───feedback
│   │   │   │       responses.php
│   │   │   │       tickets.php
│   │   │   └───notification
│   │   │           inactivity.php
│   │   │           notifications.php
│   │   │           whatsapp.php
│   │   └───timezone
│   │           status.php
│   └───app
│       ├───config
│       │       app.config.php
│       │       services.config.php
│       ├───core
│       │   │   Database.php
│       │   ├───exceptions
│       │   │       DatabaseException.php
│       │   │       ValidationException.php
│       │   └───interfaces
│       │           ServiceInterface.php
│       ├───models
│       │       Lead.php
│       │       Property.php
│       │       User.php
│       └───services
│           │   CampaignService.php
│           ├───analytics
│           │       AnalyticsService.php
│           ├───feedback
│           │       FeedbackService.php
│           ├───influencer
│           │       InfluencerService.php
│           ├───leads
│           │       LeadService.php
│           ├───notification
│           │       NotificationService.php
│           ├───property
│           │       PropertyService.php
│           └───timezone
│                   TimezoneService.php
│       ├───assets
│       │   ├───css
│       │   │   dashboard.css
│       │   │   tailwind.min.css
│       │   │   tailwindcss-stable.min.css
│       │   └───flags
│       │       ae.png
│       │       au.png
│       │       brazil.png
│       │       ca.png
│       │       cn.png
│       │       de.png
│       │       gb.png
│       │       in.png
│       │       us.png
│       ├───config
│       │   db.config.local.php
│       │   db.config.php
│       ├───database
│       │   enhanced_schema.sql
│       │   mock_data.sql
│       │   └───seeds
│       │           f63845733780033.sql
│       ├───includes
│       │   init.php
│       │   wp-integration.php
│       └───public
│           manifest.json
│           offline.html
│           sw.js
│       └───src
│           ... (see src/ for full React/TSX structure)
```
</details>

## 🚀 Getting Started
1. Clone the repo: `git clone <repo-url> && cd Real-Estate`
2. Install frontend deps: `npm install`
3. Configure DB in `config/db.config.local.php`
4. Import schema: `mysql -u root -p real_estate_local < database/enhanced_schema.sql`
5. Start dev server: `npm run dev`
6. Access: Frontend at http://localhost:5173, API at http://localhost/Real-Estate/api/

## 🏢 Production Deployment
- Upload all PHP, built React (`dist/`), and config files to your server (e.g., GoDaddy)
- Update `config/db.config.php` for production DB
- Import schema via phpMyAdmin
- Ensure `.htaccess` is set for React Router

## 🔗 API Endpoints (Sample)
- `POST /api/auth/login.php` — User login
- `POST /api/auth/register.php` — User registration
- `GET /api/admin/users.php` — List users
- `GET /api/analytics/track.php` — Analytics tracking
- `POST /api/feedback/tickets.php` — Create feedback ticket
- `POST /api/auth/kyc.php` — KYC upload
- ...and more (see `/api/`)

## 👥 User Roles & Permissions
- **Admin:** User/system management, analytics, settings
- **Agent:** Property/lead management, commission
- **Builder:** Project/campaign management
- **Client:** Property search, favorites, inquiries
- **Influencer:** Campaign creation, earnings, analytics

## 🎨 UI Components
- GradientButton, Card, Modal, DashboardLayout, CountrySelector, FeedbackWidget, NotificationCenter, KYCUpload, CampaignManager, etc.

## 🔒 Security
- Password hashing, CORS, role-based access, input validation, SQL injection prevention

## 📊 Database Schema (Key Tables)
- `users`, `countries`, `properties`, `leads`, `campaigns`, `campaign_properties`, `campaign_events`, `feedback_tickets`, `user_analytics`, etc.

## 📝 Changelog (from log_file.txt)
<details>
<summary>Recent Changes</summary>

```
[2024-06-25] Initialized log_file.txt for RealtyFlow Pro Enhancement Plan.
[2024-06-25] Deleted empty config files as part of project cleanup.
[2024-06-25] Refactored Database.php for singleton DB connection.
[2024-06-25] Added/updated analytics, feedback, KYC, campaign, notification APIs.
[2024-06-25] Integrated analytics, feedback, campaign, notification, and KYC features in frontend.
[2024-06-25] Enhanced PWA support and admin tools.
[2024-06-25] Final review and polish phase completed.
```
</details>

## 🤝 Contributing
1. Fork the repo
2. Create a feature branch
3. Commit and push your changes
4. Open a Pull Request

## 🆘 Support
- Create an issue in the repo
- Contact the dev team

## 📝 License
MIT License — see [LICENSE](LICENSE)

---

*This README was auto-generated and includes a full file tree and changelog for transparency and onboarding.*
