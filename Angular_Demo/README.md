# Angular RealWorld Example App - A Modern Angular Implementation of the RealWorld Spec

A fully-featured social blogging platform built with Angular 17+ that demonstrates real-world application architecture and best practices. This application implements the RealWorld specification to create a "Medium.com clone" with authentication, articles, comments, profiles and more.

The application showcases Angular's latest features including standalone components, improved template syntax, and modern dependency injection. It demonstrates professional patterns for routing, state management, API integration, and component architecture while providing a production-ready codebase that can serve as a reference implementation.

## Repository Structure
```
angular-realworld-example-app/
├── src/                      # Source code directory
│   ├── app/                  # Application root module
│   │   ├── core/            # Core functionality (auth, interceptors, layouts)
│   │   │   ├── auth/        # Authentication components and services
│   │   │   ├── interceptors/# HTTP interceptors for API calls
│   │   │   ├── layout/      # App-wide layout components
│   │   │   └── models/      # Core data models
│   │   ├── features/        # Feature modules
│   │   │   ├── article/     # Article feature (create, edit, view articles)
│   │   │   ├── profile/     # User profile feature
│   │   │   └── settings/    # User settings feature
│   │   └── shared/          # Shared components and utilities
│   ├── index.html           # Main HTML entry point
│   └── main.ts              # Application bootstrap file
├── angular.json             # Angular CLI configuration
├── package.json             # Project dependencies and scripts
└── tsconfig.json           # TypeScript configuration
```

## Usage Instructions
### Prerequisites
- Node.js (version 18.13.0 or 20.9.0)
- npm (comes with Node.js)
- Angular CLI (`npm install -g @angular/cli`)

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd angular-realworld-example-app

# Install dependencies
npm install

# Start the development server
npm start
```

### Quick Start
1. **Register/Login**
```typescript
// Navigate to auth page
this.router.navigate(['/register']); // or '/login'

// Submit authentication form
this.authForm.setValue({
  email: 'user@example.com',
  password: 'password',
  username: 'username' // only for registration
});
```

2. **Create an Article**
```typescript
// Navigate to editor
this.router.navigate(['/editor']);

// Submit article
this.articleForm.setValue({
  title: 'Article Title',
  description: 'Short description',
  body: 'Article content',
  tagList: ['tag1', 'tag2']
});
```

### More Detailed Examples
1. **Interacting with Articles**
```typescript
// Favorite an article
articlesService.favorite(slug).subscribe(article => {
  console.log('Article favorited:', article);
});

// Add a comment
commentsService.add(slug, 'Great article!').subscribe(comment => {
  console.log('Comment added:', comment);
});
```

2. **Managing Profile**
```typescript
// Follow a user
profileService.follow(username).subscribe(profile => {
  console.log('Now following:', profile.username);
});

// Update settings
userService.update({
  email: 'new@email.com',
  bio: 'Updated bio',
  image: 'new-image-url'
}).subscribe();
```

### Troubleshooting
1. **Authentication Issues**
- Error: "User not authenticated"
  - Check if JWT token is present in localStorage
  - Verify token expiration
  - Clear browser storage and re-login

2. **API Connection Issues**
- Error: "API endpoint not responding"
  - Check network connection
  - Verify API base URL in interceptors
  - Look for CORS issues in browser console

3. **Performance Optimization**
- Enable production mode for better performance
```typescript
// main.ts
enableProdMode();
```
- Use trackBy with ngFor to improve list rendering
```html
<div *ngFor="let item of items; trackBy: trackByFn">
```

## Data Flow
The application follows a unidirectional data flow pattern where services manage API communication and components handle presentation logic.

```ascii
User Action → Component → Service → HTTP Interceptor → API
     ↑                                                  ↓
     └──────────── State Update ← Observable ←──────────┘
```

Key Component Interactions:
1. Authentication flow through JWT token interceptor
2. Article data managed by ArticlesService with CRUD operations
3. Profile updates handled by ProfileService
4. Comments managed by CommentsService with real-time updates
5. User settings synchronized through UserService
6. API requests processed through custom HTTP interceptors
7. Error handling centralized in ErrorInterceptor