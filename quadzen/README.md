# Quadzen - Student Productivity & Wellness App

A comprehensive Flutter application designed to help students manage their academic life, track habits, and maintain mental wellness through journaling and reflection.

## Features

### 🎯 Core Functionality
- **Bullet Journaling**: Digital bullet journal with tasks, events, and notes
- **Habit Tracking**: Build and monitor daily habits with streak tracking
- **Mood Tracking**: Log daily mood and energy levels
- **Academic Management**: Course tracking and assignment management
- **Calendar Integration**: Unified view of tasks, events, and deadlines
- **Reflection System**: Daily, weekly, and monthly reflection prompts

### 🔐 Authentication
- **Email/Password Authentication**: Secure user registration and login
- **Google OAuth** *(Configuration Required)*: Single sign-on with Google account
- **Profile Management**: User profile and preferences

### 📱 Cross-Platform
- **Flutter Framework**: Native performance on iOS and Android
- **Responsive Design**: Optimized for various screen sizes
- **Offline Support**: Core features work without internet connection

## Google Authentication Setup

**Important**: Google OAuth authentication requires additional configuration in your Supabase project:

### Step 1: Configure Supabase Authentication
1. Go to your Supabase Dashboard
2. Navigate to Authentication → Settings
3. Click on "Add Provider" and select "Google"
4. Enable the Google provider
5. Add your Google OAuth credentials:
   - **Client ID**: Your Google OAuth 2.0 Client ID
   - **Client Secret**: Your Google OAuth 2.0 Client Secret

### Step 2: Configure Google OAuth Redirect URLs
Add these redirect URLs in both Google Cloud Console and Supabase:
- `https://[your-supabase-project-id].supabase.co/auth/v1/callback`
- `io.supabase.quadzen://login-callback` (for mobile apps)

### Step 3: Google Cloud Console Setup
1. Create a project in Google Cloud Console
2. Enable Google+ API or Google Identity service
3. Create OAuth 2.0 credentials
4. Add authorized redirect URIs as mentioned above

### Error Troubleshooting
If you see "Unsupported provider: provider is not enabled":
- Verify Google provider is enabled in Supabase Auth settings
- Check that OAuth credentials are correctly entered
- Ensure redirect URLs match exactly
- Confirm Google Cloud Console project is properly configured

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/quadzen.git
   cd quadzen
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create environment variables for Supabase:
   ```bash
   flutter run --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
   ```

4. **Database Setup**
   Run the migration in your Supabase project:
   ```sql
   -- Execute the SQL file: supabase/migrations/20250711070000_quadzen_with_auth.sql
   ```

## Architecture

### Project Structure
```
lib/
├── core/               # Core utilities and exports
├── models/             # Data models
├── presentation/       # UI screens and widgets
├── services/           # API and business logic
├── theme/              # App theming
├── routes/             # Navigation routes
└── widgets/            # Reusable UI components
```

### Key Services
- **AuthService**: Authentication and user management
- **TaskService**: Task and event CRUD operations
- **HabitService**: Habit tracking and logging
- **SupabaseService**: Database connection and queries

## Database Schema

The app uses Supabase (PostgreSQL) with the following main tables:
- `user_profiles`: Extended user information
- `collections`: Custom page system for organization
- `tasks`: Bullet journal entries (tasks, events, notes)
- `habits`: User habit definitions
- `habit_logs`: Daily habit completion tracking
- `mood_entries`: Daily mood and energy tracking
- `courses`: Academic course management
- `assignments`: Course assignment tracking
- `events`: Calendar events
- `reflections`: Reflection entries

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support with Google authentication setup or other issues:
1. Check the troubleshooting section above
2. Review Supabase authentication documentation
3. Create an issue in this repository

---

Built with ❤️ using Flutter and Supabase