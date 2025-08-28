# Quadzen - Student Productivity & Wellness Application
## Comprehensive Technical Documentation

![Quadzen Logo](https://placeholder.com/quadzen-logo)

## Table of Contents
1. [Introduction](#introduction)
2. [Project Overview](#project-overview)
3. [Architecture](#architecture)
4. [Technical Stack](#technical-stack)
5. [System Components](#system-components)
6. [Data Model](#data-model)
7. [Authentication System](#authentication-system)
8. [Core Functionalities](#core-functionalities)
9. [Implementation Details](#implementation-details)
10. [Deployment Guidelines](#deployment-guidelines)
11. [Conclusion](#conclusion)

## Introduction <a name="introduction"></a>

Quadzen is a comprehensive Flutter-based mobile application designed to enhance student productivity and wellness. The application provides an integrated platform for academic management, habit tracking, mood monitoring, and journaling - addressing the diverse needs of students in managing their academic and personal lives.

## Project Overview <a name="project-overview"></a>

### Purpose
Quadzen aims to help students navigate the challenges of academic life while maintaining mental wellness through:
- Organized task and academic management
- Habit formation and tracking
- Mood and emotional health monitoring
- Structured reflection and journaling

### Target Audience
- College and university students
- High school students with demanding academic schedules
- Anyone looking to improve productivity with a focus on mental wellness

## Architecture <a name="architecture"></a>

### High-Level Architecture Diagram

```
┌───────────────────────────────────────────────────┐
│                  Presentation Layer                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │    Views    │  │   Widgets   │  │   Screens   │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
└───────────────────────────────────────────────────┘
                        ▲
                        │
                        ▼
┌───────────────────────────────────────────────────┐
│                   Business Layer                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │  Services   │  │ Controllers │  │    Blocs    │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
└───────────────────────────────────────────────────┘
                        ▲
                        │
                        ▼
┌───────────────────────────────────────────────────┐
│                     Data Layer                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │   Models    │  │ Repositories│  │ Data Sources│ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
└───────────────────────────────────────────────────┘
                        ▲
                        │
                        ▼
┌───────────────────────────────────────────────────┐
│                External Services                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │  Supabase   │  │Google Auth  │  │   Storage   │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
└───────────────────────────────────────────────────┘
```

### Project Structure

The application follows a layered architecture with clear separation of concerns:

```
lib/
├── core/               # Core utilities and exports
│   ├── constants/      # Application constants
│   ├── errors/         # Error handling
│   └── utils/          # Utility functions
│
├── models/             # Data models
│   ├── user.dart       # User model
│   ├── task.dart       # Task model
│   ├── habit.dart      # Habit model
│   └── ...             # Other data models
│
├── presentation/       # UI screens and widgets
│   ├── auth/           # Authentication screens
│   ├── dashboard/      # Main dashboard
│   ├── tasks/          # Task management screens
│   ├── habits/         # Habit tracking screens
│   └── ...             # Other UI components
│
├── services/           # API and business logic
│   ├── auth_service.dart      # Authentication
│   ├── supabase_service.dart  # Database operations
│   ├── task_service.dart      # Task management
│   ├── habit_service.dart     # Habit tracking
│   └── ...                    # Other services
│
├── theme/              # App theming
│   ├── colors.dart     # Color definitions
│   ├── typography.dart # Text styles
│   └── theme.dart      # Theme configuration
│
├── routes/             # Navigation routes
│   └── app_router.dart # App navigation configuration
│
└── widgets/            # Reusable UI components
    ├── buttons/        # Custom buttons
    ├── cards/          # Custom cards
    └── ...             # Other widgets
```

## Technical Stack <a name="technical-stack"></a>

### Frontend
- **Framework**: Flutter
- **State Management**: [Likely using Provider, Bloc, or Riverpod]
- **UI Components**: Custom Flutter widgets with responsive design

### Backend
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth with Email/Password and Google OAuth
- **API**: Supabase REST API and Realtime subscriptions

### Storage
- **Local Storage**: Flutter secure storage for credentials
- **Remote Storage**: Supabase storage for user-generated content

## System Components <a name="system-components"></a>

### Authentication Module
Handles user registration, login, and session management using Supabase authentication.

### Task Management System
Manages the bullet journal features including tasks, events, and notes.

### Habit Tracking System
Facilitates habit definition, tracking, and streak calculations.

### Mood Monitoring
Records and analyzes user mood and energy levels.

### Academic Management
Tracks courses and assignments with deadline notifications.

### Calendar Integration
Provides a unified view of all scheduled activities.

### Reflection System
Implements structured journaling with prompts.

## Data Model <a name="data-model"></a>

### Entity Relationship Diagram

```
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│ user_profiles │       │  collections  │       │     tasks     │
├───────────────┤       ├───────────────┤       ├───────────────┤
│ id            │─┐     │ id            │       │ id            │
│ user_id       │ │     │ user_id       │       │ collection_id │─┐
│ display_name  │ │     │ name          │       │ title         │ │
│ avatar_url    │ │     │ color         │       │ description   │ │
│ preferences   │ │     │ created_at    │       │ status        │ │
└───────────────┘ │     └───────────────┘       │ due_date      │ │
                  │                             │ created_at    │ │
                  │                             └───────────────┘ │
                  │                                               │
                  │     ┌───────────────┐       ┌───────────────┐ │
                  │     │    habits     │       │  habit_logs   │ │
                  │     ├───────────────┤       ├───────────────┤ │
                  │     │ id            │       │ id            │ │
                  └────┐│ user_id       │       │ habit_id      │ │
                       ││ name          │       │ completed     │ │
                       ││ description   │       │ completed_at  │ │
                       ││ frequency     │       │ notes         │ │
                       ││ created_at    │       └───────────────┘ │
                       │└───────────────┘                         │
                       │                                          │
                       │  ┌───────────────┐    ┌───────────────┐  │
                       │  │ mood_entries  │    │   courses     │  │
                       │  ├───────────────┤    ├───────────────┤  │
                       │  │ id            │    │ id            │  │
                       └─┬│ user_id       │    │ user_id       │──┘
                         ││ mood_level    │    │ name          │
                         ││ energy_level  │    │ instructor    │
                         ││ notes         │    │ schedule      │
                         ││ date          │    │ color         │
                         │└───────────────┘    └───────────────┘
                         │
                         │  ┌───────────────┐    ┌───────────────┐
                         │  │  assignments  │    │ reflections   │
                         │  ├───────────────┤    ├───────────────┤
                         │  │ id            │    │ id            │
                         └─┬│ course_id     │    │ user_id       │─┘
                           ││ title         │    │ prompt        │
                           ││ description   │    │ content       │
                           ││ due_date      │    │ type          │
                           ││ status        │    │ created_at    │
                           │└───────────────┘    └───────────────┘
                           │
                           │  ┌───────────────┐
                           │  │    events     │
                           │  ├───────────────┤
                           │  │ id            │
                           └──│ user_id       │
                              │ title         │
                              │ description   │
                              │ start_time    │
                              │ end_time      │
                              │ location      │
                              └───────────────┘
```

### Key Database Tables

1. **user_profiles**: Extended user information
   - id, user_id, display_name, avatar_url, preferences

2. **collections**: Custom page organization system
   - id, user_id, name, color, created_at

3. **tasks**: Bullet journal entries
   - id, collection_id, title, description, status, due_date, created_at

4. **habits**: User habit definitions
   - id, user_id, name, description, frequency, created_at

5. **habit_logs**: Daily habit completion tracking
   - id, habit_id, completed, completed_at, notes

6. **mood_entries**: Daily mood and energy tracking
   - id, user_id, mood_level, energy_level, notes, date

7. **courses**: Academic course management
   - id, user_id, name, instructor, schedule, color

8. **assignments**: Course assignment tracking
   - id, course_id, title, description, due_date, status

9. **events**: Calendar events
   - id, user_id, title, description, start_time, end_time, location

10. **reflections**: Reflection entries
    - id, user_id, prompt, content, type, created_at

## Authentication System <a name="authentication-system"></a>

### Authentication Flow

```
┌──────────┐         ┌────────────┐         ┌─────────────┐
│  Client  │         │  Supabase  │         │  Database   │
└────┬─────┘         └──────┬─────┘         └──────┬──────┘
     │                      │                      │
     │ Email/Password Login │                      │
     │─────────────────────>│                      │
     │                      │                      │
     │                      │ Validate Credentials │
     │                      │─────────────────────>│
     │                      │                      │
     │                      │   Return User Data   │
     │                      │<─────────────────────│
     │                      │                      │
     │    Return JWT Token  │                      │
     │<─────────────────────│                      │
     │                      │                      │
     │ Store Token Locally  │                      │
     │─────────┐            │                      │
     │         │            │                      │
     │<────────┘            │                      │
     │                      │                      │
     │ API Request with JWT │                      │
     │─────────────────────>│                      │
     │                      │                      │
     │                      │ Validate JWT Token   │
     │                      │──────┐               │
     │                      │      │               │
     │                      │<─────┘               │
     │                      │                      │
     │                      │ Execute DB Operation │
     │                      │─────────────────────>│
     │                      │                      │
     │                      │   Return Results     │
     │                      │<─────────────────────│
     │                      │                      │
     │      Return Data     │                      │
     │<─────────────────────│                      │
     │                      │                      │
┌────┴─────┐         ┌──────┴─────┐         ┌──────┴──────┐
│  Client  │         │  Supabase  │         │  Database   │
└──────────┘         └────────────┘         └─────────────┘
```

### Google OAuth Integration

Quadzen implements Google OAuth for seamless authentication:

1. **Configuration**: Set up in Supabase dashboard and Google Cloud Console
2. **Redirect URLs**: Configured for both web and mobile platforms
3. **Token Handling**: JWT tokens for maintaining user sessions
4. **Error Handling**: Comprehensive error management for auth failures

## Core Functionalities <a name="core-functionalities"></a>

### Bullet Journaling
- **Task Management**: Create, edit, and delete tasks
- **Status Tracking**: Mark tasks as pending, in progress, or completed
- **Custom Collections**: Organize tasks into custom collections

### Habit Tracking
- **Habit Definition**: Create and customize habits with frequency
- **Streak Calculation**: Track consecutive days of habit completion
- **Progress Visualization**: Visual representations of habit adherence

### Mood Tracking
- **Daily Check-ins**: Log mood and energy levels
- **Trend Analysis**: View patterns over time
- **Reflection Prompts**: Context-aware journaling suggestions

### Academic Management
- **Course Tracking**: Record course details and schedules
- **Assignment Management**: Track deadlines and completion status
- **Progress Monitoring**: Visualize academic performance

### Calendar Integration
- **Unified View**: See tasks, habits, and events in one calendar
- **Deadline Visualization**: Color-coded display of upcoming deadlines
- **Event Management**: Create and manage calendar events

### Reflection System
- **Structured Journaling**: Guided reflection with prompts
- **Time-based Reflections**: Daily, weekly, and monthly prompts
- **Progress Review**: Look back at achievements and challenges

## Implementation Details <a name="implementation-details"></a>

### State Management

The application implements a robust state management strategy using:
- **Repository Pattern**: For data access abstraction
- **Service Layer**: For business logic
- **State Management**: For UI state (likely using Provider or Bloc)

### Code Examples

**Authentication Service:**
```dart
class AuthService {
  final SupabaseClient _supabaseClient;
  
  AuthService(this._supabaseClient);
  
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signIn(email: email, password: password);
      if (response.error != null) throw response.error!;
      return _mapUserData(response.user);
    } catch (e) {
      // Handle errors
      return null;
    }
  }
  
  Future<UserModel?> signInWithGoogle() async {
    try {
      final response = await _supabaseClient.auth.signIn(provider: Provider.google);
      if (response.error != null) throw response.error!;
      return _mapUserData(response.user);
    } catch (e) {
      // Handle errors
      return null;
    }
  }
  
  // Other auth methods...
}
```

**Task Service:**
```dart
class TaskService {
  final SupabaseClient _supabaseClient;
  
  TaskService(this._supabaseClient);
  
  Future<List<Task>> getTasks({required String collectionId}) async {
    final response = await _supabaseClient
      .from('tasks')
      .select()
      .eq('collection_id', collectionId)
      .order('created_at');
      
    return response.map((data) => Task.fromJson(data)).toList();
  }
  
  Future<Task?> createTask({
    required String collectionId,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final data = {
      'collection_id': collectionId,
      'title': title,
      'description': description,
      'status': 'pending',
      'due_date': dueDate?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
    
    final response = await _supabaseClient.from('tasks').insert(data).single();
    return Task.fromJson(response);
  }
  
  // Other task methods...
}
```

### UI Implementation

The application uses a consistent design system with:
- Custom widgets for common UI patterns
- Responsive layouts for different screen sizes
- Accessibility considerations for diverse users

## Deployment Guidelines <a name="deployment-guidelines"></a>

### Environment Setup

1. **Flutter Setup**:
   ```bash
   flutter pub get
   ```

2. **Supabase Configuration**:
   ```bash
   flutter run --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
   ```

3. **Database Migration**:
   ```sql
   -- Execute in Supabase SQL Editor
   -- From file: supabase/migrations/20250711070000_quadzen_with_auth.sql
   ```

### Google Authentication Configuration

1. **Supabase Setup**:
   - Navigate to Authentication → Settings
   - Add Google provider
   - Configure Client ID and Client Secret

2. **Redirect URLs**:
   - `https://[your-supabase-project-id].supabase.co/auth/v1/callback`
   - `io.supabase.quadzen://login-callback`

3. **Google Cloud Console**:
   - Create OAuth 2.0 credentials
   - Add authorized redirect URIs

### Build and Release

For Android:
```bash
flutter build appbundle --release
```

For iOS:
```bash
flutter build ios --release
```

## Conclusion <a name="conclusion"></a>

Quadzen represents a comprehensive solution for student productivity and wellness, integrating multiple features into a cohesive platform. The application's architecture ensures maintainability and extensibility, while its feature set addresses real-world student needs.

The combination of task management, habit tracking, and wellness features makes Quadzen a valuable tool for students seeking to improve their academic performance while maintaining mental health.

---

## Appendix

### Additional Resources

- Supabase Documentation: [https://supabase.io/docs](https://supabase.io/docs)
- Flutter Documentation: [https://flutter.dev/docs](https://flutter.dev/docs)
- Google OAuth Documentation: [https://developers.google.com/identity/protocols/oauth2](https://developers.google.com/identity/protocols/oauth2)

### Glossary

- **JWT**: JSON Web Token, used for secure authentication
- **OAuth**: Open standard for access delegation
- **Supabase**: Open source Firebase alternative with PostgreSQL
- **Flutter**: Google's UI toolkit for building natively compiled applications

---

*Last Updated: August 28, 2025*