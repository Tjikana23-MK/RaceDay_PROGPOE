# RaceDay API Endpoint Plan

**Module:** Programming 2B (PROG6212/w)  
**Project:** RaceDay  
**Part:** Part 1 – System Planning and Database  
**Document:** API Endpoint Plan

---

## 1. Purpose

This document defines the planned API endpoints for the RaceDay road-event management platform. The plan describes the HTTP method, route, purpose, required user role, request body and expected response for each endpoint.

The API is planned around the two user roles used by RaceDay:

- **Organiser** – manages events and categories, views enrolments for their events, and captures race results.
- **Participant** – manages their own profile, views events and categories, enrols in events, and views their own race results.

The API plan is intended to guide the implementation of Part 2. The endpoint routes and responsibilities should remain consistent when the API is implemented.

---

## 2. User Roles

| Role | Main Responsibilities |
|---|---|
| Organiser | Create, update and delete their own events; manage event categories; view enrolments for their events; capture and update results. |
| Participant | View and update their own profile; browse events and categories; enrol in events; view their own enrolments and results. |

---

## 3. API Endpoint Plan

### 3.1 Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | `/api/auth/register` | Creates a new RaceDay user account. The account can be registered as an Organiser or Participant. | None | `{ "firstName": "string", "lastName": "string", "email": "string", "password": "string", "role": "Organiser/Participant", "phone": "string" }` | **201 Created** – account created. **400 Bad Request** – invalid details. **409 Conflict** – email already exists. |
| POST | `/api/auth/login` | Authenticates a registered user and starts an authenticated server-side session containing the user's identity and role. | None | `{ "email": "string", "password": "string" }` | **200 OK** – login successful. **401 Unauthorized** – incorrect email or password. |
| POST | `/api/auth/logout` | Ends the currently authenticated user's session. | Any authenticated user | None | **200 OK** – session ended. **401 Unauthorized** – no active session. |

### 3.2 User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | `/api/profile` | Returns the profile information belonging to the currently authenticated user. | Organiser / Participant | None | **200 OK** – profile returned. **401 Unauthorized** – user is not logged in. |
| PUT | `/api/profile` | Updates the currently authenticated user's personal profile information. | Organiser / Participant | `{ "firstName": "string", "lastName": "string", "phone": "string", "profilePictureUrl": "string" }` | **200 OK** – profile updated. **400 Bad Request** – invalid data. **401 Unauthorized** – user is not logged in. |

### 3.3 Event Types

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | `/api/event-types` | Returns available event types such as Run, Walk and Cycle. | None | None | **200 OK** – event types returned successfully. |

### 3.4 Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | `/api/events` | Returns upcoming RaceDay events and can support filtering by event type, date or location. | None | None | **200 OK** – list of events returned. |
| GET | `/api/events/{id}` | Returns the details of one event, including its available categories. | None | None | **200 OK** – event details returned. **404 Not Found** – event does not exist. |
| POST | `/api/events` | Creates a new road event. | Organiser | `{ "name": "string", "description": "string", "eventDate": "YYYY-MM-DD", "location": "string", "distanceKm": 10.0, "eventTypeId": 1, "bannerImageUrl": "string" }` | **201 Created** – event created. **400 Bad Request** – invalid data. **401 Unauthorized** – not logged in. **403 Forbidden** – user is not an Organiser. |
| PUT | `/api/events/{id}` | Updates an event managed by the authenticated Organiser. | Organiser | `{ "name": "string", "description": "string", "eventDate": "YYYY-MM-DD", "location": "string", "distanceKm": 10.0, "eventTypeId": 1, "bannerImageUrl": "string" }` | **200 OK** – event updated. **400 Bad Request** – invalid data. **403 Forbidden** – Organiser does not own the event. **404 Not Found** – event does not exist. |
| DELETE | `/api/events/{id}` | Deletes an event managed by the authenticated Organiser. | Organiser | None | **204 No Content** – event deleted. **403 Forbidden** – Organiser does not own the event. **404 Not Found** – event does not exist. |

### 3.5 Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | `/api/events/{eventId}/categories` | Returns all available categories belonging to a specific event. | None | None | **200 OK** – categories returned. **404 Not Found** – event does not exist. |
| POST | `/api/events/{eventId}/categories` | Creates an age or distance category for an event managed by the Organiser. | Organiser | `{ "categoryName": "string", "minAge": 18, "maxAge": null, "categoryDistanceKm": 10.0 }` | **201 Created** – category created. **400 Bad Request** – invalid category data. **403 Forbidden** – Organiser does not own the event. **404 Not Found** – event does not exist. |
| PUT | `/api/categories/{id}` | Updates an existing category belonging to an event managed by the Organiser. | Organiser | `{ "categoryName": "string", "minAge": 18, "maxAge": null, "categoryDistanceKm": 10.0 }` | **200 OK** – category updated. **400 Bad Request** – invalid data. **403 Forbidden** – user does not manage the related event. **404 Not Found** – category does not exist. |
| DELETE | `/api/categories/{id}` | Deletes a category belonging to an event managed by the Organiser. | Organiser | None | **204 No Content** – category deleted. **403 Forbidden** – user does not manage the related event. **404 Not Found** – category does not exist. **409 Conflict** – category is already used by an enrolment. |

### 3.6 Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | `/api/events/{eventId}/enrolments` | Records a Participant's enrolment in an event and selected category. | Participant | `{ "categoryId": 1 }` | **201 Created** – enrolment recorded. **400 Bad Request** – invalid category. **404 Not Found** – event or category does not exist. **409 Conflict** – Participant is already enrolled. |
| GET | `/api/enrolments/mine` | Returns events entered by the currently authenticated Participant. | Participant | None | **200 OK** – Participant's enrolments returned. **401 Unauthorized** – user is not logged in. |
| GET | `/api/events/{eventId}/enrolments` | Returns Participants enrolled in an event, including selected category and enrolment status. | Organiser | None | **200 OK** – enrolments returned. **403 Forbidden** – Organiser does not manage the event. **404 Not Found** – event does not exist. |
| GET | `/api/enrolments/{id}` | Returns details of a specific enrolment when the authenticated user has permission to view it. | Organiser / Participant | None | **200 OK** – enrolment returned. **403 Forbidden** – user has no permission. **404 Not Found** – enrolment does not exist. |

### 3.7 Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | `/api/events/{eventId}/results` | Captures a Participant's finish time and finishing position after an event. | Organiser | `{ "enrolmentId": 1, "finishTimeSeconds": 3150, "finishingPosition": 1 }` | **201 Created** – result recorded. **400 Bad Request** – invalid result. **403 Forbidden** – Organiser does not manage the event. **404 Not Found** – event or enrolment does not exist. |
| PUT | `/api/results/{id}` | Updates an existing race result if a correction is required. | Organiser | `{ "finishTimeSeconds": 3150, "finishingPosition": 1 }` | **200 OK** – result updated. **400 Bad Request** – invalid result data. **403 Forbidden** – access denied. **404 Not Found** – result does not exist. |
| GET | `/api/results/mine` | Returns the authenticated Participant's personal race history. | Participant | None | **200 OK** – personal results returned. **401 Unauthorized** – user is not logged in. |
| GET | `/api/events/{eventId}/results` | Returns results recorded for an event for organiser review. | Organiser | None | **200 OK** – event results returned. **403 Forbidden** – Organiser does not manage the event. **404 Not Found** – event does not exist. |

---

## 4. HTTP Status Code Guide

| Status Code | Meaning | Typical Use |
|---|---|---|
| 200 OK | Request completed successfully. | GET, PUT and successful logout operations. |
| 201 Created | A new resource was successfully created. | Registration, event creation, category creation, enrolment and result creation. |
| 204 No Content | Request completed successfully without a response body. | Delete operations. |
| 400 Bad Request | Request contains invalid or incomplete information. | Validation failures. |
| 401 Unauthorized | Authentication is required or credentials are incorrect. | Login/session failures. |
| 403 Forbidden | User is authenticated but does not have permission. | Participant attempting Organiser-only operations or an Organiser accessing another organiser's resources. |
| 404 Not Found | Requested resource does not exist. | Invalid event, category, enrolment or result ID. |
| 409 Conflict | Request conflicts with existing data or a database constraint. | Duplicate email, duplicate enrolment or a category already used by an enrolment. |

---

## 5. Security and Validation Considerations

1. Authentication must be required for protected operations.
2. The user's role must be checked before allowing Organiser-only operations.
3. Organisers must only modify or delete events and categories that they manage.
4. Participants must only access their own protected profile, enrolments and results.
5. Passwords must never be stored as plain text and should be hashed before storage.
6. Input should be validated before database operations are performed.
7. Foreign-key relationships must be respected when creating events, categories, enrolments and results.
8. Duplicate enrolments must be prevented.
9. Invalid IDs should return `404 Not Found` rather than causing an unhandled server error.
10. Database and server errors should be handled safely without exposing sensitive implementation details.

---

## 6. Endpoint Summary

The planned API contains **23 endpoints**:

| Area | Number of Endpoints |
|---|---:|
| Authentication | 3 |
| User Profile | 2 |
| Event Types | 1 |
| Events | 5 |
| Categories | 4 |
| Event Enrolments | 4 |
| Results | 4 |
| **Total** | **23** |

---

## 7. Relationship to the RaceDay Database

The endpoint plan is designed to work with the six entities in the RaceDay database:

1. `Users`
2. `EventTypes`
3. `Events`
4. `Categories`
5. `Enrolments`
6. `Results`

The API uses these relationships when processing requests. An Event references an Organiser through `OrganiserID` and an EventType through `EventTypeID`. A Category belongs to an Event, while an Enrolment connects a Participant, Event and Category. A Result is associated with an Enrolment.

---

## 8. References

Institute of Education (2026) *PROGRAMMING 2B PROG6212/w: RaceDay POE Part 1 – System Planning and Database*. IIE.

Microsoft (n.d.) *CREATE TABLE (Transact-SQL)*. Microsoft Learn.

Microsoft (n.d.) *Primary and foreign key constraints*. Microsoft Learn.

Microsoft (n.d.) *Unique constraints and CHECK constraints*. Microsoft Learn.
