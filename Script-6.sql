CREATE TABLE projects (
    project_id VARCHAR(10) PRIMARY KEY,
    project_name VARCHAR(150),
    project_status VARCHAR(30),
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    planned_budget NUMERIC(15,2),
    actual_cost_to_date NUMERIC(15,2),
    cost_variance NUMERIC(15,2),
    forecasted_project_cost NUMERIC(15,2),
    cost_overrun_probability NUMERIC(5,2),
    delay_risk_level VARCHAR(20),
    project_health_score INT,
    risk_priority_index INT,
    beneficiary_type VARCHAR(30),
    beneficiary_importance_level VARCHAR(20),
    business_impact_score INT
);

CREATE TABLE employees (
    employee_id VARCHAR(10) PRIMARY KEY,
    department VARCHAR(50),
    level VARCHAR(30),
    primary_skill VARCHAR(50),
    available_hours INT,
    left_organization VARCHAR(5)
);

CREATE TABLE allocations (
    employee_id VARCHAR(10),
    project_id VARCHAR(10),
    onboarded_date DATE,
    offboarded_date DATE,
    allocated_hours INT,
    allocation_ratio NUMERIC(5,2),
    allocation_status VARCHAR(30),
    overtime_hours INT,
    resource_utilization_efficiency VARCHAR(30),
    burnout_risk_level VARCHAR(20),
    consecutive_working_days INT,
    progress_percentage INT,
    delay_days INT,
    idle_hours INT,
    requirement_needed VARCHAR(5)
);

SELECT COUNT(*) FROM projects;
SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM allocations;


SELECT *
FROM allocations
ORDER BY onboarded_date DESC
LIMIT 2;

select *
from allocations where employee_id ='E00001';

DELETE FROM allocations
WHERE employee_id = '123';

SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM projects;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'public';
