# HR Portal Admin - Backend API Requirements

> **Last Updated:** 2026-03-28
> **Project:** HR Portal Admin (Flutter Mobile App)
> **Base URL:** `{{BASE_URL}}/api/v1`
> **Auth:** Bearer Token (header: `Authorization: Bearer {token}`)

---

## Response Format (Standard)

All APIs must return responses in this format:

```json
{
  "status": true,
  "code": 200,
  "message": "Success message",
  "data": { ... },
  "trace_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

### Error Response

```json
{
  "status": false,
  "code": 422,
  "message": "Validation failed",
  "error_code": "VALIDATION_FAILED",
  "errors": {
    "field_name": ["Error message"]
  },
  "trace_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

### Error Codes Reference

| Error Code | HTTP Status | Description |
|---|---|---|
| `AUTH_REQUIRED` | 401 | Token missing |
| `TOKEN_EXPIRED` | 401 | Token expired |
| `TOKEN_INVALID` | 401 | Token invalid |
| `ACCESS_DENIED` | 403 | No access |
| `INSUFFICIENT_PERMISSIONS` | 403 | Not authorized for this action |
| `VALIDATION_FAILED` | 422 | Input validation failed |
| `BUSINESS_RULE_VIOLATION` | 422 | Business logic error |
| `RESOURCE_NOT_FOUND` | 404 | Resource not found |
| `RESOURCE_CONFLICT` | 409 | Duplicate or conflict |
| `RATE_LIMITED` | 429 | Too many requests |
| `SERVER_ERROR` | 500 | Internal server error |
| `SERVICE_UNAVAILABLE` | 503 | Service down |

### Pagination Format

```json
{
  "data": [ ... ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 73
  }
}
```

---

---

# Section 1: NEW APIs (Must Build from Scratch)

---

## 1. Admin Tasks Management

> Admin can create, assign, track, and manage tasks for employees across departments.

### 1.1 GET `/admin/tasks`

**Description:** List all admin tasks with filtering and pagination.

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `status` | string | No | Filter: `pending`, `in_progress`, `overdue`, `completed` |
| `priority` | string | No | Filter: `high`, `normal`, `low` |
| `department_id` | integer | No | Filter by department |
| `assigned_to` | integer | No | Filter by employee ID |
| `search` | string | No | Search in title and notes |
| `per_page` | integer | No | Default: 15 |
| `page` | integer | No | Default: 1 |

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Tasks retrieved successfully",
  "data": {
    "tasks": [
      {
        "id": 1,
        "title": "مراجعة تقييمات الأداء",
        "assigned_to": {
          "id": 5,
          "name": "أحمد محمد"
        },
        "department": {
          "id": 2,
          "name": "الموارد البشرية"
        },
        "created_date": "2025-03-01",
        "due_date": "2025-03-15",
        "status": "in_progress",
        "priority": "high",
        "notes": "يجب الانتهاء قبل نهاية الربع"
      }
    ],
    "stats": {
      "total": 45,
      "pending": 12,
      "in_progress": 18,
      "overdue": 5,
      "completed": 10
    },
    "meta": {
      "current_page": 1,
      "last_page": 3,
      "per_page": 15,
      "total": 45
    }
  },
  "trace_id": "uuid"
}
```

---

### 1.2 GET `/admin/tasks/{id}`

**Description:** Get single task details.

**Path Parameters:**

| Param | Type | Required |
|---|---|---|
| `id` | integer | Yes |

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Task retrieved successfully",
  "data": {
    "id": 1,
    "title": "مراجعة تقييمات الأداء",
    "assigned_to": {
      "id": 5,
      "name": "أحمد محمد",
      "position": "مدير الموارد البشرية",
      "avatar": "https://..."
    },
    "department": {
      "id": 2,
      "name": "الموارد البشرية"
    },
    "created_by": {
      "id": 1,
      "name": "المشرف العام"
    },
    "created_date": "2025-03-01",
    "due_date": "2025-03-15",
    "status": "in_progress",
    "priority": "high",
    "notes": "يجب الانتهاء قبل نهاية الربع",
    "updated_at": "2025-03-10T14:30:00Z"
  },
  "trace_id": "uuid"
}
```

---

### 1.3 POST `/admin/tasks`

**Description:** Create a new task.

**Request Body:**

```json
{
  "title": "مراجعة تقييمات الأداء",
  "assigned_to": 5,
  "department_id": 2,
  "due_date": "2025-03-15",
  "priority": "high",
  "notes": "يجب الانتهاء قبل نهاية الربع"
}
```

**Validation Rules:**

| Field | Type | Required | Rules |
|---|---|---|---|
| `title` | string | Yes | min:3, max:255 |
| `assigned_to` | integer | Yes | exists:employees,id |
| `department_id` | integer | No | exists:departments,id |
| `due_date` | date | Yes | format:Y-m-d, after_or_equal:today |
| `priority` | string | Yes | in:high,normal,low |
| `notes` | string | No | max:1000 |

**Success Response (201):**

```json
{
  "status": true,
  "code": 201,
  "message": "Task created successfully",
  "data": {
    "id": 46,
    "title": "مراجعة تقييمات الأداء",
    "assigned_to": { "id": 5, "name": "أحمد محمد" },
    "department": { "id": 2, "name": "الموارد البشرية" },
    "created_date": "2025-03-28",
    "due_date": "2025-03-15",
    "status": "pending",
    "priority": "high",
    "notes": "يجب الانتهاء قبل نهاية الربع"
  },
  "trace_id": "uuid"
}
```

---

### 1.4 PUT `/admin/tasks/{id}`

**Description:** Update an existing task.

**Request Body (partial update):**

```json
{
  "title": "string (optional)",
  "assigned_to": "integer (optional)",
  "department_id": "integer (optional)",
  "due_date": "date (optional)",
  "status": "string (optional): pending|in_progress|overdue|completed",
  "priority": "string (optional): high|normal|low",
  "notes": "string|null (optional)"
}
```

**Validation Rules:**

| Field | Type | Required | Rules |
|---|---|---|---|
| `title` | string | No | min:3, max:255 |
| `assigned_to` | integer | No | exists:employees,id |
| `department_id` | integer | No | exists:departments,id |
| `due_date` | date | No | format:Y-m-d |
| `status` | string | No | in:pending,in_progress,overdue,completed |
| `priority` | string | No | in:high,normal,low |
| `notes` | string/null | No | max:1000 |

**Success Response (200):** Same structure as GET `/admin/tasks/{id}`

---

### 1.5 DELETE `/admin/tasks/{id}`

**Description:** Delete a task.

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Task deleted successfully",
  "data": null,
  "trace_id": "uuid"
}
```

---

---

## 2. Follow-up Items Management

> Tracks overdue items, escalations, and pending approvals that need admin follow-up.

### 2.1 GET `/admin/follow-ups`

**Description:** List all follow-up items with filtering.

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `status` | string | No | `pending`, `in_progress`, `overdue`, `completed` |
| `type` | string | No | `task`, `approval`, `hr`, `finance` |
| `is_overdue` | boolean | No | `true` to show only overdue items |
| `is_escalated` | boolean | No | `true` to show only escalated items |
| `department_id` | integer | No | Filter by department |
| `search` | string | No | Search in title |
| `per_page` | integer | No | Default: 15 |
| `page` | integer | No | Default: 1 |

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Follow-up items retrieved successfully",
  "data": {
    "follow_ups": [
      {
        "id": 1,
        "title": "اعتماد ميزانية التدريب",
        "responsible": {
          "id": 3,
          "name": "خالد العمري"
        },
        "department": {
          "id": 4,
          "name": "المالية"
        },
        "due_date": "2025-03-12",
        "status": "overdue",
        "type": "finance",
        "is_overdue": true,
        "is_escalated": false,
        "created_at": "2025-03-01T08:00:00Z"
      }
    ],
    "stats": {
      "total": 30,
      "pending": 8,
      "in_progress": 10,
      "overdue": 7,
      "escalated": 3,
      "completed": 5
    },
    "meta": {
      "current_page": 1,
      "last_page": 2,
      "per_page": 15,
      "total": 30
    }
  },
  "trace_id": "uuid"
}
```

---

### 2.2 GET `/admin/follow-ups/{id}`

**Description:** Get single follow-up item details.

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Follow-up item retrieved successfully",
  "data": {
    "id": 1,
    "title": "اعتماد ميزانية التدريب",
    "responsible": {
      "id": 3,
      "name": "خالد العمري",
      "position": "المدير المالي",
      "avatar": "https://..."
    },
    "department": {
      "id": 4,
      "name": "المالية"
    },
    "due_date": "2025-03-12",
    "status": "overdue",
    "type": "finance",
    "is_overdue": true,
    "is_escalated": false,
    "description": "تفاصيل إضافية عن البند",
    "related_entity": {
      "type": "expense",
      "id": 15
    },
    "history": [
      {
        "action": "created",
        "by": "النظام",
        "at": "2025-03-01T08:00:00Z"
      },
      {
        "action": "status_changed",
        "from": "pending",
        "to": "overdue",
        "by": "النظام",
        "at": "2025-03-13T00:00:00Z"
      }
    ],
    "created_at": "2025-03-01T08:00:00Z",
    "updated_at": "2025-03-13T00:00:00Z"
  },
  "trace_id": "uuid"
}
```

---

### 2.3 PUT `/admin/follow-ups/{id}`

**Description:** Update follow-up item status.

**Request Body:**

```json
{
  "status": "in_progress",
  "notes": "تم التواصل مع المسؤول"
}
```

**Validation Rules:**

| Field | Type | Required | Rules |
|---|---|---|---|
| `status` | string | Yes | in:pending,in_progress,completed |
| `notes` | string | No | max:1000 |

**Success Response (200):** Same structure as GET `/admin/follow-ups/{id}`

---

### 2.4 POST `/admin/follow-ups/{id}/escalate`

**Description:** Escalate a follow-up item to higher management.

**Request Body:**

```json
{
  "reason": "تجاوز الموعد النهائي بأسبوع",
  "escalate_to": 1
}
```

**Validation Rules:**

| Field | Type | Required | Rules |
|---|---|---|---|
| `reason` | string | Yes | min:5, max:500 |
| `escalate_to` | integer | No | exists:employees,id |

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Item escalated successfully",
  "data": {
    "id": 1,
    "is_escalated": true,
    "escalated_at": "2025-03-28T10:00:00Z",
    "escalated_to": { "id": 1, "name": "المدير العام" },
    "escalation_reason": "تجاوز الموعد النهائي بأسبوع"
  },
  "trace_id": "uuid"
}
```

---

---

## 3. Documents Management

> Admin can browse, upload, and manage employee documents organized by categories.

### 3.1 GET `/admin/documents/categories`

**Description:** Get document categories with counts.

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Categories retrieved successfully",
  "data": {
    "categories": [
      {
        "key": "contracts",
        "label": "عقود العمل",
        "icon": "description",
        "count": 109
      },
      {
        "key": "insurance",
        "label": "وثائق التأمين",
        "icon": "shield",
        "count": 102
      },
      {
        "key": "certificates",
        "label": "الشهادات والمؤهلات",
        "icon": "school",
        "count": 89
      },
      {
        "key": "requests",
        "label": "طلبات الوثائق",
        "icon": "request_page",
        "count": 14
      },
      {
        "key": "policies",
        "label": "سياسات الشركة",
        "icon": "policy",
        "count": 22
      },
      {
        "key": "travel",
        "label": "وثائق السفر",
        "icon": "flight",
        "count": 8
      }
    ],
    "total_documents": 344
  },
  "trace_id": "uuid"
}
```

---

### 3.2 GET `/admin/documents`

**Description:** List documents with filtering.

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `category` | string | No | `contracts`, `insurance`, `certificates`, `requests`, `policies`, `travel` |
| `employee_id` | integer | No | Filter by employee |
| `department_id` | integer | No | Filter by department |
| `search` | string | No | Search in title, employee name |
| `per_page` | integer | No | Default: 15 |
| `page` | integer | No | Default: 1 |

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Documents retrieved successfully",
  "data": {
    "documents": [
      {
        "id": 1,
        "title": "عقد عمل - أحمد محمد",
        "category": "contracts",
        "category_label": "عقود العمل",
        "employee": {
          "id": 5,
          "name": "أحمد محمد"
        },
        "file_url": "https://storage.example.com/documents/contract_001.pdf",
        "file_name": "contract_001.pdf",
        "file_type": "pdf",
        "file_size": 245000,
        "uploaded_by": {
          "id": 1,
          "name": "المشرف العام"
        },
        "uploaded_at": "2025-02-15T10:30:00Z"
      }
    ],
    "meta": {
      "current_page": 1,
      "last_page": 8,
      "per_page": 15,
      "total": 109
    }
  },
  "trace_id": "uuid"
}
```

---

### 3.3 GET `/admin/documents/{id}`

**Description:** Get single document details.

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Document retrieved successfully",
  "data": {
    "id": 1,
    "title": "عقد عمل - أحمد محمد",
    "category": "contracts",
    "category_label": "عقود العمل",
    "employee": {
      "id": 5,
      "name": "أحمد محمد",
      "department": "الموارد البشرية"
    },
    "file_url": "https://storage.example.com/documents/contract_001.pdf",
    "file_name": "contract_001.pdf",
    "file_type": "pdf",
    "file_size": 245000,
    "uploaded_by": {
      "id": 1,
      "name": "المشرف العام"
    },
    "uploaded_at": "2025-02-15T10:30:00Z",
    "description": "عقد عمل لمدة سنتين",
    "expiry_date": "2027-02-15",
    "tags": ["عقد", "دوام كامل"]
  },
  "trace_id": "uuid"
}
```

---

### 3.4 POST `/admin/documents`

**Description:** Upload a new document. **Content-Type: `multipart/form-data`**

**Request Body (multipart):**

| Field | Type | Required | Rules |
|---|---|---|---|
| `title` | string | Yes | min:3, max:255 |
| `category` | string | Yes | in:contracts,insurance,certificates,requests,policies,travel |
| `employee_id` | integer | No | exists:employees,id |
| `file` | file | Yes | mimes:pdf,doc,docx,jpg,png,jpeg / max:10240 (10MB) |
| `description` | string | No | max:1000 |
| `expiry_date` | date | No | format:Y-m-d, after:today |
| `tags` | string | No | comma-separated tags |

**Success Response (201):**

```json
{
  "status": true,
  "code": 201,
  "message": "Document uploaded successfully",
  "data": {
    "id": 345,
    "title": "شهادة تدريب - أحمد محمد",
    "category": "certificates",
    "file_url": "https://storage.example.com/documents/cert_345.pdf",
    "file_name": "cert_345.pdf",
    "file_type": "pdf",
    "file_size": 180000,
    "uploaded_at": "2025-03-28T12:00:00Z"
  },
  "trace_id": "uuid"
}
```

---

### 3.5 DELETE `/admin/documents/{id}`

**Description:** Delete a document.

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Document deleted successfully",
  "data": null,
  "trace_id": "uuid"
}
```

---

---

## 4. Payroll Management

> View employee payroll history and monthly payslip details.

### 4.1 GET `/payroll`

**Description:** List payroll months for the authenticated employee.

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `year` | integer | No | Filter by year (default: current year) |
| `per_page` | integer | No | Default: 12 |
| `page` | integer | No | Default: 1 |

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Payroll retrieved successfully",
  "data": {
    "payroll": [
      {
        "month": "2025-03",
        "month_label": "مارس 2025",
        "basic_salary": 8000.00,
        "total_allowances": 2500.00,
        "total_deductions": 850.00,
        "net_salary": 9650.00,
        "status": "paid",
        "payment_date": "2025-03-25",
        "currency": "SAR"
      },
      {
        "month": "2025-02",
        "month_label": "فبراير 2025",
        "basic_salary": 8000.00,
        "total_allowances": 2500.00,
        "total_deductions": 500.00,
        "net_salary": 10000.00,
        "status": "paid",
        "payment_date": "2025-02-25",
        "currency": "SAR"
      }
    ],
    "summary": {
      "ytd_gross": 31500.00,
      "ytd_deductions": 2100.00,
      "ytd_net": 29400.00
    },
    "meta": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 12,
      "total": 3
    }
  },
  "trace_id": "uuid"
}
```

---

### 4.2 GET `/payroll/{month}`

**Description:** Get detailed payslip for a specific month.

**Path Parameters:**

| Param | Type | Required | Example |
|---|---|---|---|
| `month` | string | Yes | `2025-03` (format: Y-m) |

**Success Response (200):**

```json
{
  "status": true,
  "code": 200,
  "message": "Payslip retrieved successfully",
  "data": {
    "month": "2025-03",
    "month_label": "مارس 2025",
    "employee": {
      "id": 5,
      "name": "أحمد محمد",
      "position": "مدير الموارد البشرية",
      "department": "الموارد البشرية",
      "employee_number": "EMP-005"
    },
    "earnings": [
      { "label": "الراتب الأساسي", "amount": 8000.00, "type": "earning" },
      { "label": "بدل سكن", "amount": 1500.00, "type": "earning" },
      { "label": "بدل مواصلات", "amount": 500.00, "type": "earning" },
      { "label": "بدل طبيعة عمل", "amount": 500.00, "type": "earning" }
    ],
    "deductions": [
      { "label": "التأمينات الاجتماعية", "amount": 600.00, "type": "deduction" },
      { "label": "خصم غياب (1 يوم)", "amount": 250.00, "type": "deduction" }
    ],
    "total_earnings": 10500.00,
    "total_deductions": 850.00,
    "net_salary": 9650.00,
    "status": "paid",
    "payment_date": "2025-03-25",
    "payment_method": "bank_transfer",
    "currency": "SAR",
    "working_days": {
      "total": 22,
      "worked": 21,
      "absent": 1,
      "leave": 0,
      "overtime_hours": 0
    }
  },
  "trace_id": "uuid"
}
```

---

---

# Section 2: EXISTING APIs (Verify They Work Correctly)

> These APIs already have Flutter repository implementations. The backend just needs to verify they return the expected structure.

## 5. Auth (4 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `POST` | `/auth/login` | Implemented |
| `POST` | `/auth/logout` | Implemented |
| `POST` | `/auth/logout-all` | Implemented |
| `POST` | `/change-password` | Implemented |

---

## 6. Profile (2 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/profile` | Implemented |
| `PUT` | `/profile` | Implemented |

---

## 7. Employee Leaves (4 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/leaves` | Implemented |
| `POST` | `/leaves` | Implemented |
| `GET` | `/leaves/{id}` | Implemented |
| `DELETE` | `/leaves/{id}` | Implemented |

---

## 8. Employee Requests (3 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/requests` | Implemented |
| `POST` | `/requests` | Implemented |
| `GET` | `/requests/{id}` | Implemented |

---

## 9. Manager Requests (3 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/manager/requests` | Implemented |
| `GET` | `/manager/requests/{id}` | Implemented |
| `POST` | `/manager/requests/{id}/decide` | Implemented |

---

## 10. Manager Leaves (3 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/manager/leaves` | Implemented |
| `GET` | `/manager/leaves/{id}` | Implemented |
| `POST` | `/manager/leaves/{id}/decide` | Implemented |

---

## 11. Employee Attendance (1 Endpoint) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/attendance/history` | Implemented |

---

## 12. Admin Dashboard (1 Endpoint) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/admin/dashboard` | Implemented |

**Important:** Verify the dashboard response includes all of these sections:

```json
{
  "data": {
    "kpis": {
      "total_employees": "integer",
      "present_today": "integer",
      "absent_today": "integer",
      "on_leave": "integer",
      "pending_requests": "integer",
      "pending_leaves": "integer"
    },
    "departments_summary": [
      { "id": 1, "name": "string", "employee_count": 10, "present_count": 8 }
    ],
    "pending_requests": [ "...top 5 pending requests..." ],
    "overdue_tasks": [ "...overdue tasks list..." ],
    "recent_announcements": [ "...last 3 announcements..." ],
    "recent_activity": [
      { "action": "string", "actor": "string", "time": "datetime", "description": "string" }
    ]
  }
}
```

---

## 13. Admin Employees (2 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/admin/employees` | Implemented |
| `GET` | `/admin/employees/{id}` | Implemented |

---

## 14. Admin Departments (2 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/admin/departments` | Implemented |
| `GET` | `/admin/departments/{id}` | Implemented |

---

## 15. Admin Attendance (2 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/admin/attendance` | Implemented |
| `GET` | `/admin/attendance/{id}` | Implemented |

---

## 16. Admin Announcements (5 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/admin/announcements` | Implemented |
| `POST` | `/admin/announcements` | Implemented |
| `PUT` | `/admin/announcements/{id}` | Implemented |
| `POST` | `/admin/announcements/{id}/publish` | Implemented |
| `DELETE` | `/admin/announcements/{id}` | Implemented |

---

## 17. Admin Projects (5 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/admin/projects` | Implemented |
| `GET` | `/admin/projects/{id}` | Implemented |
| `GET` | `/admin/projects/{id}/tasks` | Implemented |
| `GET` | `/admin/projects/{id}/milestones` | Implemented |
| `GET` | `/admin/projects/{id}/analytics` | Implemented |

---

## 18. Admin Expenses (4 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/admin/expenses` | Implemented |
| `GET` | `/admin/expenses/{id}` | Implemented |
| `POST` | `/admin/expenses/{id}/approve` | Implemented |
| `POST` | `/admin/expenses/{id}/reject` | Implemented |

---

## 19. Admin Reports (4 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `GET` | `/admin/reports/kpis` | Implemented |
| `GET` | `/admin/reports/attendance-trend` | Implemented |
| `GET` | `/admin/reports/leave-analysis` | Implemented |
| `GET` | `/admin/reports/task-completion` | Implemented |

---

## 20. Notifications (2 Endpoints) -- Already Implemented

| Method | Endpoint | Status |
|---|---|---|
| `POST` | `/notifications/send` | Implemented |
| `POST` | `/notifications/send-to-user` | Implemented |

---

---

# Summary

## New APIs to Build

| # | Feature | Endpoints | Priority |
|---|---|---|---|
| 1 | Admin Tasks Management | 5 endpoints (CRUD) | HIGH |
| 2 | Follow-up Items | 4 endpoints | HIGH |
| 3 | Documents Management | 5 endpoints (with file upload) | MEDIUM |
| 4 | Payroll / Payslip | 2 endpoints | MEDIUM |
| | **Total New** | **16 endpoints** | |

## Existing APIs to Verify

| # | Feature | Endpoints |
|---|---|---|
| 1-16 | Auth, Profile, Leaves, Requests, Attendance, Dashboard, Employees, Departments, Announcements, Projects, Expenses, Reports, Notifications | **47 endpoints** |

## Grand Total: 63 Endpoints (16 new + 47 existing)
