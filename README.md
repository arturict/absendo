# Absendo 

**Absendo** is a tool designed to simplify the process of filling out absence forms for students of the BBZW (Berufsbildungszentrum Wirtschaft, Informatik und Technik). By integrating directly with your school calendar, Absendo automates the task of generating absence forms, saving students time and effort.

## ✨ Current Features

### ✅ Implemented
*   **User Authentication** - Secure sign-up and login
*   **User Profiles** - Store student and trainer information
*   **Onboarding Flow** - First-time setup wizard with calendar URL input
*   **Automated Form Filling** - Pre-fill absence forms with calendar data
*   **School Calendar Integration** - Import absence data from BBZW iCal feeds
*   **PDF Generation** - Export absence forms as PDF files
*   **End-to-End Encryption** - Client-side encryption for sensitive data (calendar URLs, personal info)
*   **PIN Protection** - Optional PIN-based access control for encrypted data
*   **Dashboard** - View recent absences and quick actions
*   **Contact Form** - Submit feedback and bug reports
*   **Data Privacy** - Detailed privacy policy and data handling documentation
*   **Responsive Design** - Mobile-friendly interface with Tailwind CSS + DaisyUI

### 🔜 Planned/Missing Features
*   **Batch Absence Export** - Download multiple absence forms at once (CSV/Excel)
*   **Calendar Sync Status** - Visual indicator for sync state and last update
*   **Absence History** - Full searchable history with filters
*   **Multi-language Support** - German, French, Italian translations
*   **Email Notifications** - Notify users of new absence possibilities
*   **Admin Dashboard** - School administrator features for bulk management
*   **API Documentation** - Public API for third-party integrations
*   **Two-Factor Authentication** - Enhanced security with 2FA
*   **Audit Logging** - Track all user actions for compliance
*   **Rate Limiting & DDoS Protection** - Security hardening

## 🌐 Live Demo

Experience Absendo live: [https://absendo.app](https://absendo.app)

## 📦 Project Structure

This repository contains the **full-stack** Absendo application:
- **Frontend:** React 19 + TypeScript + Vite (in `src/`)
- **Backend:** Self-hosted Supabase (PostgreSQL + Auth API)
- **Deployment:** Coolify on self-hosted infrastructure

## 🚀 Technologies

*   **Frontend:**
    *   [TypeScript](https://www.typescriptlang.org/)
    *   [React 19](https://react.dev/)
    *   [Vite 6](https://vitejs.dev/) (Build Tool)
    *   [Tailwind CSS 4](https://tailwindcss.com/) (Styling)
    *   [DaisyUI 5](https://daisyui.com/) (Component Library)
    *   [React Router DOM v7](https://reactrouter.com/) (Client-side routing)
    *   [crypto-js](https://github.com/brix/crypto-js) (Encryption)
    *   [pdf-lib](https://pdf-lib.js.org/) (PDF generation)
    *   [ical](https://www.npmjs.com/package/ical) (iCal parsing)
    *   [cally](https://www.npmjs.com/package/cally) (Calendar UI)

*   **Backend:**
    *   [Supabase](https://supabase.com/) (Auth, Database, APIs)
    *   [PostgreSQL 15+](https://www.postgresql.org/)

*   **Deployment:**
    *   [Coolify](https://coolify.io/) (Self-hosted PaaS)
    *   Self-hosted Infrastructure (Docker)

## 🛠️ Installation & Local Setup

To get a local copy of Absendo up and running, follow these steps:

### Prerequisites

*   Node.js 18+ (LTS version recommended)
*   npm or bun package manager
*   [Bun](https://bun.sh) (v1.0 or higher recommended)
*   Git

### Clone the repository

```bash
git clone https://github.com/notacodes/absendo-react.git
cd absendo
```

### Install Dependencies

```bash
bun install
```

### Environment Variables

Create a `.env` file in the root of the project:

```env
# Supabase configuration
VITE_SUPABASE_URL=https://db.yourdomain.com
VITE_SUPABASE_ANON_KEY=your_anon_key_here

# Optional: API endpoint if different
VITE_API_URL=https://api.yourdomain.com
```

**For Self-Hosted Supabase Setup:** See [DEPLOYMENT.md](./DEPLOYMENT.md)

## 🚀 Deployment

This application is deployed on **Coolify** at `cloud.artur.engineer`.

**📋 For detailed deployment instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md)**

**Quick Links:**

- **Production:** https://absendo.artur.engineer
- **Health Check:** https://absendo.artur.engineer/health
- **Coolify Dashboard:** https://cloud.artur.engineer

**Deployment Features:**
- ✅ Automatic deployment via GitHub webhook
- ✅ Docker-based deployment with Nginx
- ✅ Built-in health checks
- ✅ SSL/TLS via Let's Encrypt
- ✅ Resource-optimized multi-stage build

### Run the Development Server

```bash
bun run dev
```

This will start the development server at `http://localhost:5173`.

### Build for Production

```bash
npm run build
npm run preview
```

## 📋 Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production (TypeScript + Vite) |
| `npm run lint` | Run ESLint code quality checks |
| `npm run preview` | Preview production build locally |

## 📚 Documentation

- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Self-host Supabase on Coolify
- **[GEMINI.md](./GEMINI.md)** - Copilot AI instructions
- **[.github/copilot-instructions.md](./.github/copilot-instructions.md)** - Additional Copilot guidance

## 🏗️ Architecture

### Pages (12 total)
- **Home** - Landing page with features overview
- **Login** - User authentication
- **Signup** - New user registration
- **Onboarding** - First-time setup with trainer info and calendar URL
- **Dashboard** - Main interface showing recent absences
- **All Absences** - View complete absence history
- **Profile** - Manage user settings and personal information
- **Email Verification** - Email confirmation flow
- **Contact** - Feedback and support form
- **Datenschutz** - Privacy policy
- **PinTest** - PIN verification (security testing)
- **Maintenance** - Server maintenance page

### Services
- **EncryptionService** - Handles encryption/decryption of sensitive data
- **SaltManager** - Manages encryption salts for key derivation
- **pdfService** - Generates PDF absence forms

### Data Model
- **profiles** - User profiles with encrypted fields (calendar_url, trainer info)
- **absences** - Absence records with dates, reasons, and excusal status

## 🔐 Security & Privacy

- **End-to-End Encryption** - Calendar URLs and sensitive data encrypted client-side
- **PBKDF2 Key Derivation** - User ID + email + PIN → encryption key
- **Salts** - Per-user encryption salts stored in database
- **PIN Protection** - Optional PIN-based access control
- **No Logging** - Sensitive data never logged
- **GDPR Compliant** - Full data export/deletion support

## 🤝 Contributing

We welcome contributions! To contribute:

1. **Fork** the repository
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Code Standards
- Use TypeScript for all new code
- Follow existing code style and component patterns
- Run `npm run lint` before committing
- Ensure `npm run build` passes
- Write meaningful commit messages

## 🐛 Known Issues & Limitations

- Currently Swiss German-focused (German UI and documentation)
- Calendar integration limited to BBZW iCal format
- PIN system is optional but recommended for security
- Single-language UI (translation support in roadmap)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Thanks

Special thanks to everyone who shared their SLUZ URL for testing purposes — your help made this tool possible.
Thanks also to [dDreistein](https://github.com/dDreistein) for designing the favicon.

## 📞 Support

- **Issues:** Report bugs or request features via GitHub Issues
- **Discussions:** Join our community discussions
- **Email:** Contact through the in-app feedback form