# Coffee Management System (PolyCafe)

## Overview
PolyCafe is a web-based coffee shop management system developed using Java Servlet and JSP.

The system simulates a real POS (Point of Sale) workflow, allowing staff to create bills, process payments, and manage products, while administrators can manage users, monitor bills, and view revenue reports.

---

## Main Features

### 🔐 Authentication & Security
- Login / Logout (session-based)
- Register account with email
- Forgot password & reset password via email
- Remember Me (cookie)
- Filters:
  - AuthFilter (authentication)
  - AdminFilter (authorization)
  - XssFilter (basic security)
  - RateLimitFilter (request control)
  - Utf8Filter (encoding)

---

### 📦 Product Management (Admin)
- Add / Edit / Delete drinks
- Upload and update product images
- Search by keyword
- Pagination (10 items/page)
- Show / Hide product (status)

---

### 👤 User Management (Admin)
- View user list
- Change role (Admin / Staff)
- Delete user (soft/hard depending on logic)

---

### 🧾 Billing & Payment (Staff)

#### ✔ Create Bill
- Select drinks
- Input quantity
- Preview bill (total calculation)

#### ✔ Cash Payment
- Input customer money
- Calculate change
- Save bill with status **PAID**

#### ✔ Bank Payment (PayOS)
- Create bill with status **PENDING**
- Generate QR code for payment
- Check payment status via API
- Update bill to **PAID** when success

---

### 📊 Reports & Statistics (Admin)
- Total revenue
- Revenue today
- Number of bills today
- Average order value
- Revenue chart (last 7 days)
- Revenue by staff

---

## Database Design

The system uses 4 main tables:

- **Users**
  - username (PK), password, fullname, email, phone
  - role (Admin / Staff)
  - is_deleted

- **Drinks**
  - drink_id (PK), name, price, category
  - status, image

- **Bills**
  - bill_id (PK), created_date, username
  - total_amount, payment_status
  - payment_method (cash / bank)
  - order_code, payment_link_id, paid_at

- **BillDetails**
  - detail_id (PK)
  - bill_id (FK), drink_id (FK)
  - quantity, price

---

## System Architecture

- MVC Pattern:
  - Controller: Servlet
  - View: JSP
  - Model: Entity + DAO

- Client – Server model:
  - Browser → Tomcat → Database

---

## Technologies Used

- Java Servlet / JSP
- JPA (Hibernate)
- SQL Server
- Apache Tomcat 10
- Maven
- HTML, CSS, Bootstrap
- Chart.js (for reports)
- PayOS (QR payment integration)

---

## Testing

Manual testing was performed for all main features :contentReference[oaicite:1]{index=1}

### Test Scope:
- Authentication (Login, Register, Forgot Password)
- Product management
- User management
- Billing & Payment
- Reports & Authorization

### Test Methods:
- Manual Testing
- Black-box Testing
- Functional Testing
- Negative Testing
- Authorization Testing
- Database verification

### Result Summary:
- Total test cases: 46
- Passed: 41
- Failed: 5

### Key Issues Found:
- Missing input validation (register, price)
- Admin can delete itself
- Payment total trusted from client (security risk)
- Pending bills not handled when payment canceled

---

## Setup & Run

### Requirements:
- JDK 17+
- Apache Tomcat 10.x
- SQL Server
- IntelliJ IDEA / Eclipse
