# Business Intelligence System for Project Analysis and Resource Management


## Overview

The **Business Intelligence System for Project Analysis and Resource Management** is a data-driven platform designed to help organizations monitor project performance, optimize resource allocation, and identify operational risks through advanced analytics and visualization.

The system integrates:

* **PostgreSQL** for structured data storage
* **Streamlit (Python)** for a web-based data management interface
* **Power BI** for advanced business intelligence dashboards

This solution enables project managers and stakeholders to gain **real-time insights into project progress, resource utilization, cost performance, and risk indicators**, supporting better decision-making and improved project outcomes.

---

# Project Motivation

Organizations managing multiple projects often face challenges such as:

* Difficulty tracking project status across teams
* Inefficient resource allocation
* Delays caused by lack of performance visibility
* Cost overruns and schedule deviations
* Manual data handling through spreadsheets

Traditional reporting methods do not provide sufficient analytical capability or real-time monitoring.

This project addresses these issues by creating a **centralized analytics system** that integrates data management, operational tracking, and business intelligence visualization.

---

# System Architecture

The system consists of **three main layers**.

## 1. Data Management Layer

A **PostgreSQL relational database** stores structured project data including:

* Employee information
* Project details
* Resource allocations
* Department information

This centralized database ensures:

* Data consistency
* Scalable storage
* Reliable querying for analytics

---

## 2. Data Input Interface

A **Streamlit web application** provides an intuitive interface for managing project data.

Users can perform:

* Create records
* Read data
* Update entries
* Delete allocations

The application interacts directly with the PostgreSQL database using **SQLAlchemy** and **Pandas**, allowing real-time updates and validation.

---

## 3. Business Intelligence Layer

**Power BI dashboards** provide advanced analytics and visual reporting.

These dashboards analyze:

* Portfolio performance
* Budget utilization
* Project delays
* Resource workload
* Employee burnout risk

Power BI connects to the centralized data source to produce interactive visualizations and KPI tracking.

---

# Key Features

## Role-Based Access Control

The system supports multiple user roles with different permissions:

### Admin

* Full system access
* Manage employees and projects
* Execute SQL queries
* Edit master data
* View dashboards

### Project Head

* Monitor project performance
* Allocate resources
* View analytics dashboards

### Project User

* Manage resource allocations for assigned projects
* View project-specific insights

### Viewer

* Read-only access to project data

---

# Resource Management Capabilities

The platform provides advanced resource management features:

* Real-time employee allocation tracking
* Daily working hour capacity monitoring
* Over-allocation detection
* Idle resource identification
* Utilization efficiency measurement
* Burnout risk analysis

Employees have a **standard daily capacity of 10 hours**, with a maximum limit of **14 hours per day** allowed through controlled overrides.

---

# Analytical Insights

The Power BI dashboards provide deep analytics across several dimensions.

## Portfolio Performance

Metrics include:

* Total number of projects
* Active projects
* Completed projects
* Projects on hold
* Portfolio health score

---

## Financial Analysis

The dashboard evaluates financial performance through:

* Budget vs actual cost comparison
* Forecast cost projections
* Budget utilization percentage
* Cost variance distribution
* Client-level budget distribution

These metrics help identify **projects at risk of cost overruns**.

---

## Project Performance Analytics

Performance is evaluated using project management metrics such as:

* **SPI (Schedule Performance Index)**
* **CPI (Cost Performance Index)**
* Critical path delays
* Complexity factors

Projects are categorized into performance groups:

* High efficiency
* On track
* Slight overrun
* Critical overrun

---

## Resource Utilization Analysis

Workforce analytics includes:

* Employee workload distribution
* Resource allocation across projects
* Overtime monitoring
* Idle resource tracking
* Allocation status (Bench / Allocated / Overallocated)

---

## Workforce Risk Monitoring

Advanced analysis also measures workforce wellbeing indicators:

* Burnout risk
* Attrition probability
* Delay vs burnout relationship
* High-risk projects affecting employee stress

These insights help organizations maintain **sustainable team productivity**.

---

# Technology Stack

## Programming Language

Python

## Data Management

PostgreSQL

## Data Interface

Streamlit

## Business Intelligence

Power BI

## Python Libraries

* Streamlit
* Pandas
* SQLAlchemy
* Psycopg2

---

# Database Structure

The system uses four main tables.

## Employees

Stores employee information including:

* Employee ID
* Department
* Skill
* Level
* Designation
* Employment status

---

## Projects

Stores project-level information such as:

* Project ID
* Project name
* Client name
* Project status
* Planned and actual timelines

---

## Allocations

Tracks employee resource allocation across projects including:

* Allocated hours
* Onboarded date
* Offboarded date
* Delay days
* Active employee status

---

## Departments

Stores department metadata used for employee classification.

---

# Streamlit Application Modules

The Streamlit application provides multiple modules.

## Authentication Module

Users log in through a role-based authentication system which determines their access privileges.

---

## Admin Dashboard

The admin dashboard provides system-wide metrics including:

* Total projects
* Active employees
* Idle resources
* Open project requirements
* Project status distribution

Admins can also execute **custom SQL queries directly within the application**.

---

## Master Data Management

Admins can manage:

* Employee records
* Project details
* Department information

Employee updates automatically offboard employees from active allocations when they leave the organization.

---

## Resource Allocation Management

Users can create or update employee allocations with:

* Onboarding date
* Offboarding date
* Allocated hours
* Delay days
* Active status

The system automatically performs validation checks to prevent:

* Duplicate allocations
* Over-capacity allocations
* Invalid project assignments

---

## Data Filtering and Querying

The system provides flexible data filtering features including:

* Field-level search
* Partial value filtering
* Custom date range filters

These tools enable users to quickly analyze operational data.

---

# Example Insights Generated

The system can generate insights such as:

* Projects at risk of cost overruns
* Employees with excessive workload
* Idle workforce capacity
* Budget utilization across clients
* Burnout risk across project teams
* Resource allocation efficiency

---

# Installation Guide

## 1. Clone the Repository

```
git clone https://github.com/yourusername/project-bi-system.git
```

---

## 2. Install Dependencies

```
pip install -r requirements.txt
```

---

## 3. Configure Database

Update the PostgreSQL connection string in the application:

```
create_engine("postgresql+psycopg2://username:password@localhost:5432/project_bi")
```

---

## 4. Run the Streamlit Application

```
streamlit run app.py
```


# Future Improvements

Potential enhancements include:

* Cloud deployment of the Streamlit application
* Automated project delay prediction using machine learning
* Real-time database streaming
* Email alerts for resource over-allocation
* Integration with enterprise project management tools

---

# Conclusion

This project demonstrates how integrating **database management, web-based interfaces, and business intelligence tools** can transform raw project data into actionable insights.

By combining **Streamlit, PostgreSQL, and Power BI**, the system provides a scalable and practical solution for modern project analytics, enabling organizations to optimize resources, reduce operational risks, and improve project delivery performance.
