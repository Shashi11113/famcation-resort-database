# FamCation Resort Database Project

## Overview

**FamCation Resort** is a luxury, family-friendly mountain resort located near rivers and scenic hiking areas. It is known for guided outdoor activities such as hiking, mountain biking, horseback riding, and rafting.

As the resort expanded, its original database system became outdated:

- Poor schema design  
- Slow performance  
- Frequent downtime  
- Difficulty scaling bookings, activities, and employees  

This project fully redesigns the FamCation database into a **modern, normalized, scalable SQL Server system**. It models real-world operations such as guest bookings, employee roles, condo management, and activity reservations.

Originally built in phases for coursework, the project has been reorganized into a **professional, portfolio-ready database system**.

---

## Business Problem

FamCation required a new system to manage:

### ✔ 1. Employees  
- Managers  
- Technology support  
- Guides  
- Housekeepers  

**Guides** track certifications (renew every 2 years).  
**Housekeepers** track shifts (1–3) and status (perm/temp).

### ✔ 2. Condos & Cleaning  
- Condos use a **composite key**: BuildingNumber + UnitNumber  
- Tracks sq ft, bedrooms, bathrooms, daily rate  
- Cleaning is logged by housekeepers using a **ScheduleID** (surrogate key)

### ✔ 3. Guests & Families  
- Guests have VIP membership numbers (GuestID)  
- Children stored in FAMILY table (GuestID + ChildFirstName composite key)

### ✔ 4. Bookings  
- BookID, GuestID, StartDate, EndDate  
- Condo fee = DailyRate × Nights  
- Every condo has at least one booking

### ✔ 5. Activities & Reservations  
- Activities: ActID, description, hours, PPP, distance, type  
- Reservations connect guest → activity → guide  
- Activity cost = PPP × NumberInParty  

---

## Data Model (EERD)

Place the file in GitHub under:

```
diagrams/FamCation_Resort_EERD.pdf
```

This diagram visually represents every rule above and serves as the architectural blueprint for the database.

---

## Sample Data (Seed Script)

This project includes a **demo-friendly seed script**:

```
data/02_seed_data.sql
```

### What It Contains  
A **minimal dataset** giving enough information to:

- Run all queries  
- Test joins, windows, and groupings  
- Execute the invoice stored procedure  
- Ensure the database works “out of the box”

### It Inserts Sample Rows For:
- **Employees**  
- **Guides** + certification details  
- **Housekeepers**  
- **Guide Levels**  
- **Condos**  
- **Guests**  
- **Bookings**  
- **Activities**  
- **Reservations**

### Why This Exists  
The full instructor dataset is large and contained in .docx files.  
This lightweight seed:

- Loads instantly  
- Makes the repo runnable without extra files  
- Prevents bloat in your GitHub repo  
- Demonstrates your SQL system clearly and quickly to recruiters

---

## Major Entities

### EMPLOYEE
General employee info (name, contact, department, manager, salary).

### GUIDE (Subtype of EMPLOYEE)
Adds certification level, date, renewal date, badge color, training hours.

### HOUSEKEEPER (Subtype of EMPLOYEE)
Shift assignment + perm/temp status.

### CONDO
Composite key: `BldgNum + UnitNum`, includes sqft, bedrooms, bathrooms, rate.

### CLEANING
Schedule of condo cleaning tasks with surrogate key `ScheduleID`.

### GUEST
VIP membership info, contact details, spouse name.

### FAMILY
Children of guests.

### BOOKING
Guest stays at condos + fee calculation.

### ACTIVITY
Outdoor activities with PPP pricing and duration.

### RESERVATION
Guest or employee activity reservations with cost = PPP × NumberInParty.

---

## SQL Features Demonstrated

### 🔹 Data Manipulation (DML)
- SELECT INTO  
- UPDATE with arithmetic  
- DELETE  
- Derived columns  

### 🔹 Filtering & Pagination
- Date filtering  
- OFFSET…FETCH  

### 🔹 Aggregations & Window Functions
- GROUP BY, HAVING  
- SUM() OVER  
- COUNT() OVER  
- ROW_NUMBER()  
- RANK()  
- PARTITION BY  

### 🔹 Joins & Subqueries
- Multi-table joins  
- Anti-joins  
- NOT EXISTS  
- NOT IN  
- Correlated subqueries  

### 🔹 CTEs & Views
- Top housekeepers logic as VIEW, CTE, SUBQUERY  
- Ranking examples  

### 🔹 Stored Procedures (Invoice System)
Procedure computes:
- CondoFee  
- ActivityFee  
- InvoiceTotal  
- SalesTax  
- GrandTotal  

Uses:
- TRY/CATCH  
- Transactions  
- SCOPE_IDENTITY()  

---

## Suggested Repository Structure

```
famcation-resort-database/
├─ README.md
│
├─ schema/
│  └─ 01_schema.sql
│
├─ data/
│  ├─ 02_seed_data.sql
│  └─ full_data.docx
│
├─ queries/
│  ├─ 01_data_manipulation_basics.sql
│  ├─ 02_grouping_and_windows.sql
│  ├─ 03_joins_and_subqueries.sql
│  ├─ 04_ctes_and_views.sql
│  └─ 05_invoice_demo.sql
│
├─ procedures/
│  └─ create_invoice.sql
│
├─ diagrams/
│  └─ FamCation_Resort_EERD.pdf
│
└─ documents/
   ├─ FamCation EERD Solution Explained.docx
   └─ FamCation Insert Record Scripts.docx
```

---

## How to Run (SQL Server)

### 1️⃣ Create Database + Tables  
Run:
```
schema/01_schema.sql
```

### 2️⃣ Insert Sample Data  
Run:
```
data/02_seed_data.sql
```

### 3️⃣ Create Stored Procedures  
Run:
```
procedures/create_invoice.sql
```

### 4️⃣ Explore Queries  
Run scripts under `/queries` to test:
- Guest analytics  
- Reservations  
- Activity insights  
- Employee workloads  
- Invoice generation  

---

## Final Notes

This project demonstrates:

- Professional relational design  
- Real-world SQL workflows  
- Strong documentation  
- Advanced SQL techniques  
- Clean GitHub structure  

Perfect for showcasing SQL and database design skills.
