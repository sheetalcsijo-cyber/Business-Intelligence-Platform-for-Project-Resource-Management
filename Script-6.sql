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


CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50) UNIQUE NOT NULL,
    department_head VARCHAR(50)
);

ALTER TABLE employees
ADD COLUMN designation VARCHAR(50),
ADD COLUMN department_id INT REFERENCES departments(department_id);

ALTER TABLE projects
ADD COLUMN actual_end_date DATE,
ADD COLUMN budget_allocated NUMERIC(12,2);

CREATE TABLE kpi_metrics (
    kpi_id SERIAL PRIMARY KEY,
    snapshot_date DATE DEFAULT CURRENT_DATE,

    utilization_pct NUMERIC(5,2),
    overallocated_pct NUMERIC(5,2),
    underutilized_pct NUMERIC(5,2),
    total_idle_hours INT,
    avg_overtime_hours NUMERIC(5,2),

    burnout_high_pct NUMERIC(5,2),
    on_time_delivery_pct NUMERIC(5,2),
    avg_delay_days NUMERIC(5,2),
    attrition_rate_pct NUMERIC(5,2),
    project_health_avg NUMERIC(5,2)
);

ALTER TABLE employees
ADD COLUMN employee_name VARCHAR(100);


-- Employee Names
UPDATE employees
SET employee_name = CONCAT('Employee ', employee_id)
WHERE employee_name IS NULL;

-- Designation
UPDATE employees
SET designation = CASE
    WHEN level = 'Fresher' THEN 'Associate'
    WHEN level = 'Junior' THEN 'Analyst'
    WHEN level = 'Mid' THEN 'Consultant'
    WHEN level = 'Senior' THEN 'Senior Consultant'
    WHEN level = 'Lead' THEN 'Team Lead'
    WHEN level = 'Manager' THEN 'Project Manager'
END
WHERE designation IS NULL;

-- Budget Allocated (Project)
UPDATE projects
SET budget_allocated = ROUND(RANDOM() * 5000000 + 1000000, 2)
WHERE budget_allocated IS NULL;

-- Actual End Date (Project)
UPDATE projects
SET actual_end_date = planned_end_date + (RANDOM() * 10)::INT
WHERE actual_end_date IS NULL;

-- Budget Allocated (Project)
UPDATE projects
SET budget_allocated = ROUND((RANDOM() * 5000000 + 1000000)::NUMERIC, 2)
WHERE budget_allocated IS NULL;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'employees'
ORDER BY ordinal_position;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'departments';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'projects'
ORDER BY ordinal_position;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'allocations'
ORDER BY ordinal_position;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'kpi_metrics';

SELECT
  tc.table_name,
  tc.constraint_name,
  kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.ordinal_position;

SELECT COUNT(*) 
FROM projects
WHERE budget_allocated IS NULL;

SELECT COUNT(*) 
FROM projects
WHERE actual_end_date IS NULL;

SELECT COUNT(*) 
FROM employees
WHERE employee_name IS NULL;

SELECT COUNT(*) 
FROM employees
WHERE employee_name IS NULL;

ALTER TABLE allocations
DROP COLUMN left_organization;

-- 1) Departments
SELECT *
FROM departments
ORDER BY department_id
LIMIT 5;

-- 2) Employees
SELECT *
FROM employees
ORDER BY employee_id;


-- 3) Projects
SELECT *
FROM projects
ORDER BY project_id
LIMIT 5;

-- 4) Allocations
SELECT *
FROM allocations
ORDER BY onboarded_date DESC
LIMIT 5;

-- 5) KPI Metrics (if you created snapshot table)
SELECT *
FROM kpi_metrics
ORDER BY snapshot_date DESC
LIMIT 5;

SELECT DISTINCT department
FROM employees
WHERE department NOT IN (
    SELECT department_name FROM departments
);

INSERT INTO departments (department_name)
SELECT DISTINCT department
FROM employees
WHERE department IS NOT NULL;

SELECT * FROM departments;

UPDATE employees e
SET department_id = d.department_id
FROM departments d
WHERE e.department = d.department_name;

SELECT employee_id, department, department_id
FROM employees
LIMIT 10;

SELECT COUNT(*) FROM employees WHERE department_id IS NULL;

ALTER TABLE employees
ALTER COLUMN department_id SET NOT NULL;

ALTER TABLE employees
ADD CONSTRAINT fk_emp_dept
FOREIGN KEY (department_id) REFERENCES departments(department_id);

UPDATE departments SET department_head = 'Amit Sharma' WHERE department_name = 'Analytics';
UPDATE departments SET department_head = 'Neha Verma' WHERE department_name = 'Delivery';
UPDATE departments SET department_head = 'Rahul Mehta' WHERE department_name = 'Operations';
UPDATE departments SET department_head = 'Priya Nair' WHERE department_name = 'Finance';
UPDATE departments SET department_head = 'Karthik Iyer' WHERE department_name = 'HR';
UPDATE departments SET department_head = 'Sneha Kulkarni' WHERE department_name = 'IT';

ALTER TABLE employees
DROP COLUMN IF EXISTS employee_name;

CREATE TABLE kpi_metrics (
    kpi_id SERIAL PRIMARY KEY,
    snapshot_date DATE UNIQUE NOT NULL,

    utilization_pct NUMERIC(5,2),
    overallocated_pct NUMERIC(5,2),
    underutilized_pct NUMERIC(5,2),
    total_idle_hours INT,
    avg_overtime_hours NUMERIC(6,2),

    burnout_high_pct NUMERIC(5,2),
    on_time_delivery_pct NUMERIC(5,2),
    avg_delay_days NUMERIC(6,2),
    attrition_rate_pct NUMERIC(5,2),

    project_health_avg NUMERIC(6,2)
);

SELECT * FROM kpi_metrics;

INSERT INTO kpi_metrics (
    snapshot_date,
    utilization_pct,
    overallocated_pct,
    underutilized_pct,
    total_idle_hours,
    avg_overtime_hours,
    burnout_high_pct,
    on_time_delivery_pct,
    avg_delay_days,
    attrition_rate_pct,
    project_health_avg
)
SELECT
    CURRENT_DATE,

    ROUND(
        100.0 * SUM(a.allocated_hours)
        / NULLIF(SUM(a.allocated_hours + COALESCE(a.idle_hours, 0)), 0),
        2
    ),

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE a.allocation_status = 'Overallocated')
        / NULLIF(COUNT(*), 0),
        2
    ),

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE a.allocation_status = 'Bench')
        / NULLIF(COUNT(*), 0),
        2
    ),

    SUM(COALESCE(a.idle_hours, 0)),

    ROUND(AVG(COALESCE(a.overtime_hours, 0)), 2),

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE a.burnout_risk_level = 'High')
        / NULLIF(COUNT(*), 0),
        2
    ),

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE COALESCE(a.delay_days, 0) = 0)
        / NULLIF(COUNT(*), 0),
        2
    ),

    ROUND(AVG(COALESCE(a.delay_days, 0)), 2),

    (
        SELECT ROUND(
            100.0 * COUNT(*) FILTER (WHERE e.left_organization = 'Yes')
            / NULLIF(COUNT(*), 0),
            2
        )
        FROM employees e
    ),

    (
        SELECT ROUND(AVG(project_health_score), 2)
        FROM (
            SELECT 
                project_id,
                100
                - (AVG(COALESCE(delay_days, 0)) * 5)
                - (AVG(COALESCE(overtime_hours, 0)) * 2)
                - (COUNT(*) FILTER (WHERE burnout_risk_level = 'High') * 3)
                AS project_health_score
            FROM allocations
            GROUP BY project_id
        ) t
    )
FROM allocations a;

TRUNCATE TABLE kpi_metrics;

INSERT INTO kpi_metrics (snapshot_date)
VALUES (CURRENT_DATE);

UPDATE kpi_metrics
SET overallocated_pct = (
    SELECT ROUND(
        100.0 * COUNT(*) FILTER (WHERE allocation_status = 'Overallocated')
        / NULLIF(COUNT(*), 0),
        2
    )
    FROM allocations
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET utilization_pct = (
    SELECT ROUND(
        100.0 * SUM(a.allocated_hours)
        / NULLIF(SUM(a.allocated_hours + COALESCE(a.idle_hours, 0)), 0),
        2
    )
    FROM allocations a
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET overallocated_pct = (
    SELECT ROUND(
        100.0 * COUNT(*) FILTER (WHERE allocation_status = 'Overallocated')
        / NULLIF(COUNT(*), 0),
        2
    )
    FROM allocations
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET underutilized_pct = (
    SELECT ROUND(
        100.0 * COUNT(*) FILTER (WHERE allocation_status = 'Bench')
        / NULLIF(COUNT(*), 0),
        2
    )
    FROM allocations
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET total_idle_hours = (
    SELECT SUM(COALESCE(idle_hours, 0))
    FROM allocations
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET avg_overtime_hours = (
    SELECT ROUND(AVG(COALESCE(overtime_hours, 0)), 2)
    FROM allocations
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET burnout_high_pct = (
    SELECT ROUND(
        100.0 * COUNT(*) FILTER (WHERE burnout_risk_level = 'High')
        / NULLIF(COUNT(*), 0),
        2
    )
    FROM allocations
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET on_time_delivery_pct = (
    SELECT ROUND(
        100.0 * COUNT(*) FILTER (WHERE COALESCE(delay_days, 0) = 0)
        / NULLIF(COUNT(*), 0),
        2
    )
    FROM allocations
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET avg_delay_days = (
    SELECT ROUND(AVG(COALESCE(delay_days, 0)), 2)
    FROM allocations
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET attrition_rate_pct = (
    SELECT ROUND(
        100.0 * COUNT(*) FILTER (WHERE left_organization = 'Yes')
        / NULLIF(COUNT(*), 0),
        2
    )
    FROM employees
)
WHERE snapshot_date = CURRENT_DATE;

UPDATE kpi_metrics
SET project_health_avg = (
    SELECT ROUND(AVG(project_health_score), 2)
    FROM (
        SELECT 
            project_id,
            100
            - (AVG(COALESCE(delay_days, 0)) * 5)
            - (AVG(COALESCE(overtime_hours, 0)) * 2)
            - (COUNT(*) FILTER (WHERE burnout_risk_level = 'High') * 3)
            AS project_health_score
        FROM allocations
        GROUP BY project_id
    ) t
)
WHERE snapshot_date = CURRENT_DATE;

SELECT *
FROM kpi_metrics
WHERE snapshot_date = CURRENT_DATE;

CREATE TABLE IF NOT EXISTS levels (
    level_id SERIAL PRIMARY KEY,
    level_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS designations (
    designation_id SERIAL PRIMARY KEY,
    designation_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO levels (level_name)
SELECT DISTINCT level
FROM employees
WHERE level IS NOT NULL
ON CONFLICT (level_name) DO NOTHING;

INSERT INTO designations (designation_name)
SELECT DISTINCT designation
FROM employees
WHERE designation IS NOT NULL
ON CONFLICT (designation_name) DO NOTHING;

ALTER TABLE employees ADD COLUMN level_id INT;
ALTER TABLE employees ADD COLUMN designation_id INT;

UPDATE employees e
SET level_id = l.level_id
FROM levels l
WHERE e.level = l.level_name;

UPDATE employees e
SET designation_id = d.designation_id
FROM designations d
WHERE e.designation = d.designation_name;

ALTER TABLE employees
ADD CONSTRAINT fk_level FOREIGN KEY (level_id) REFERENCES levels(level_id);

ALTER TABLE employees
ADD CONSTRAINT fk_designation FOREIGN KEY (designation_id) REFERENCES designations(designation_id);

ALTER TABLE employees DROP COLUMN level;
ALTER TABLE employees DROP COLUMN designation;

SELECT 
    e.employee_id,
    l.level_name,
    d.designation_name
FROM employees e
LEFT JOIN levels l ON e.level_id = l.level_id
LEFT JOIN designations d ON e.designation_id = d.designation_id
LIMIT 10;

SELECT column_name FROM information_schema.columns WHERE table_name='employees' ORDER BY ordinal_position;
SELECT column_name FROM information_schema.columns WHERE table_name='projects' ORDER BY ordinal_position;
SELECT column_name FROM information_schema.columns WHERE table_name='allocations' ORDER BY ordinal_position;

SELECT column_name FROM information_schema.columns WHERE table_name='designations';

ALTER TABLE designations ADD COLUMN level_id INT REFERENCES levels(level_id);

DROP TABLE IF EXISTS designations CASCADE;
DROP TABLE IF EXISTS levels CASCADE;

ALTER TABLE employees
ADD COLUMN IF NOT EXISTS level VARCHAR(50),
ADD COLUMN IF NOT EXISTS designation VARCHAR(50);

ALTER TABLE employees
DROP COLUMN IF EXISTS level_id,
DROP COLUMN IF EXISTS designation_id;

SELECT employee_id, department, level, designation
FROM employees
LIMIT 5;

-- Fill missing Level
UPDATE employees
SET level = CASE 
    WHEN random() < 0.33 THEN 'Fresher'
    WHEN random() < 0.66 THEN 'Intermediate'
    ELSE 'Senior'
END
WHERE level IS NULL;

-- Fill Designation logically based on Level
UPDATE employees
SET designation = CASE 
    WHEN level = 'Fresher' THEN 'Junior Analyst'
    WHEN level = 'Intermediate' THEN 'Business Analyst'
    ELSE 'Senior Analyst'
END
WHERE designation IS NULL;

ALTER TABLE projects
ADD COLUMN client_name TEXT;

UPDATE projects
SET client_name = CASE project_id
    WHEN 'P001' THEN 'AT&T'
    WHEN 'P002' THEN 'Verizon'
    WHEN 'P003' THEN 'T-Mobile'
    WHEN 'P004' THEN 'Comcast'
    ELSE 'Internal'
END;

ALTER TABLE allocations
ADD COLUMN is_current BOOLEAN DEFAULT TRUE;

ALTER TABLE allocations
ADD COLUMN is_active_employee VARCHAR(3) DEFAULT 'Yes';

ALTER TABLE allocations
DROP COLUMN IF EXISTS is_current;

select * from departments;

departments = load_table("SELECT * FROM departments")
dept_map = dict(zip(departments["department_name"], departments["department_id"]))


select * from kpi_metrics km ;

ALTER TABLE employees
ADD COLUMN daily_hours_spent INT DEFAULT 8 NOT NULL;

SELECT 
    employee_id,
    COUNT(*) AS projects_currently_doing
FROM allocations
WHERE is_active_employee = 'Yes'
GROUP BY employee_id;

SELECT 
    employee_id,
    COUNT(*) AS projects_completed
FROM allocations
WHERE offboarded_date IS NOT NULL
GROUP BY employee_id;

ALTER TABLE kpi_metrics
ADD COLUMN project_id INT;

ALTER TABLE kpi_metrics
ADD CONSTRAINT fk_kpi_project
FOREIGN KEY (project_id)
REFERENCES projects(project_id);

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'projects' AND column_name = 'project_id';

ALTER TABLE kpi_metrics
ALTER COLUMN project_id TYPE VARCHAR(50);

ALTER TABLE kpi_metrics
ADD CONSTRAINT fk_kpi_project
FOREIGN KEY (project_id)
REFERENCES projects(project_id);

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('projects', 'allocations')
  AND column_name = 'project_id';

ALTER TABLE allocations
ADD CONSTRAINT fk_alloc_project
FOREIGN KEY (project_id)
REFERENCES projects(project_id);

SELECT
    conname,
    conrelid::regclass AS child_table,
    confrelid::regclass AS parent_table
FROM pg_constraint
WHERE conname = 'fk_alloc_project';

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE (table_name, column_name) IN (
  ('allocations','employee_id'),
  ('employees','employee_id'),
  ('allocations','project_id'),
  ('projects','project_id'),
  ('kpi_metrics','project_id'),
  ('departments','department_id'),
  ('employees','department_id')
);

ALTER TABLE allocations
ADD CONSTRAINT fk_alloc_employee
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id);

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE (table_name, column_name) IN (
  ('allocations','employee_id'),
  ('employees','employee_id'),
  ('allocations','project_id'),
  ('projects','project_id')
);

SELECT DISTINCT project_id
FROM allocations
WHERE project_id NOT IN (SELECT project_id FROM projects);

SELECT DISTINCT employee_id
FROM allocations
WHERE employee_id NOT IN (SELECT employee_id FROM employees);

ALTER TABLE kpi_metrics
ADD COLUMN planned_duration_days INT,
ADD COLUMN actual_duration_days INT,
ADD COLUMN plan_to_start_ratio NUMERIC(6,2),
ADD COLUMN on_time_task_pct NUMERIC(5,2),
ADD COLUMN critical_path_delay_days INT,
ADD COLUMN spi NUMERIC(6,2),
ADD COLUMN cost_variance NUMERIC(12,2),
ADD COLUMN cpi NUMERIC(6,2),
ADD COLUMN budget_utilization_pct NUMERIC(6,2),
ADD COLUMN cost_overrun_pct NUMERIC(6,2),
ADD COLUMN estimate_at_completion NUMERIC(14,2);

SELECT
    project_id,
    (planned_end_date - planned_start_date) AS planned_duration_days
FROM projects;

SELECT
    project_id,
    (actual_end_date - actual_start_date) AS actual_duration_days
FROM projects
WHERE actual_end_date IS NOT NULL;

SELECT
    project_id,
    ROUND(
        (planned_end_date - planned_start_date)::numeric /
        NULLIF((actual_end_date - actual_start_date), 0),
        2
    ) AS plan_to_start_ratio
FROM projects
WHERE actual_end_date IS NOT NULL;

SELECT
    project_id,
    (actual_end_date - actual_start_date) -
    (planned_end_date - planned_start_date) AS critical_path_delay_days
FROM projects
WHERE actual_end_date IS NOT NULL;

SELECT
    project_id,
    ROUND(
        (planned_end_date - planned_start_date)::numeric /
        NULLIF((actual_end_date - actual_start_date), 0),
        2
    ) AS spi
FROM projects
WHERE actual_end_date IS NOT NULL;

SELECT
    project_id,
    (planned_budget - actual_cost_to_date) AS cost_variance
FROM projects;

SELECT
    project_id,
    ROUND(
        planned_budget / NULLIF(actual_cost_to_date, 0),
        2
    ) AS cpi
FROM projects;

SELECT
    project_id,
    ROUND(
        (actual_cost_to_date / NULLIF(planned_budget, 0)) * 100,
        2
    ) AS budget_utilization_pct
FROM projects;

SELECT
    project_id,
    ROUND(
        ((actual_cost_to_date - planned_budget) / NULLIF(planned_budget, 0)) * 100,
        2
    ) AS cost_overrun_pct
FROM projects;

SELECT
    project_id,
    ROUND(
        planned_budget / NULLIF(
            planned_budget / NULLIF(actual_cost_to_date, 0), 0
        ),
        2
    ) AS estimate_at_completion
FROM projects;

select * from kpi_metrics ;

UPDATE kpi_metrics k
SET
    planned_duration_days =
        (p.planned_end_date - p.planned_start_date),

    actual_duration_days =
        (p.actual_end_date - p.actual_start_date),

    plan_to_start_ratio =
        ROUND(
            (p.planned_end_date - p.planned_start_date)::numeric /
            NULLIF((p.actual_end_date - p.actual_start_date), 0),
            2
        ),

    critical_path_delay_days =
        (p.actual_end_date - p.actual_start_date) -
        (p.planned_end_date - p.planned_start_date),

    spi =
        ROUND(
            (p.planned_end_date - p.planned_start_date)::numeric /
            NULLIF((p.actual_end_date - p.actual_start_date), 0),
            2
        ),

    cost_variance =
        (p.planned_budget - p.actual_cost_to_date),

    cpi =
        ROUND(
            p.planned_budget / NULLIF(p.actual_cost_to_date, 0),
            2
        ),

    budget_utilization_pct =
        ROUND(
            (p.actual_cost_to_date / NULLIF(p.planned_budget, 0)) * 100,
            2
        ),

    cost_overrun_pct =
        ROUND(
            ((p.actual_cost_to_date - p.planned_budget) / NULLIF(p.planned_budget, 0)) * 100,
            2
        ),

    estimate_at_completion =
        ROUND(
            p.planned_budget / NULLIF(
                (p.planned_budget / NULLIF(p.actual_cost_to_date, 0)), 0
            ),
            2
        ),

    snapshot_date = CURRENT_DATE

FROM projects p
WHERE k.project_id = p.project_id
  AND p.actual_end_date IS NOT NULL;


UPDATE kpi_metrics k
SET planned_duration_days =
    (p.planned_end_date - p.planned_start_date)
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET actual_duration_days =
    (p.actual_end_date - p.actual_start_date)
FROM projects p
WHERE k.project_id = p.project_id
  AND p.actual_end_date IS NOT NULL;

UPDATE kpi_metrics k
SET plan_to_start_ratio =
    ROUND(
        (p.planned_end_date - p.planned_start_date)::numeric /
        NULLIF((p.actual_end_date - p.actual_start_date), 0),
        2
    )
FROM projects p
WHERE k.project_id = p.project_id
  AND p.actual_end_date IS NOT NULL;

UPDATE kpi_metrics k
SET critical_path_delay_days =
    (p.actual_end_date - p.actual_start_date) -
    (p.planned_end_date - p.planned_start_date)
FROM projects p
WHERE k.project_id = p.project_id
  AND p.actual_end_date IS NOT NULL;

UPDATE kpi_metrics k
SET spi =
    ROUND(
        (p.planned_end_date - p.planned_start_date)::numeric /
        NULLIF((p.actual_end_date - p.actual_start_date), 0),
        2
    )
FROM projects p
WHERE k.project_id = p.project_id
  AND p.actual_end_date IS NOT NULL;

UPDATE kpi_metrics k
SET cost_variance =
    (p.planned_budget - p.actual_cost_to_date)
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET cpi =
    ROUND(
        p.planned_budget / NULLIF(p.actual_cost_to_date, 0),
        2
    )
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET budget_utilization_pct =
    ROUND(
        (p.actual_cost_to_date / NULLIF(p.planned_budget, 0)) * 100,
        2
    )
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET cost_overrun_pct =
    ROUND(
        ((p.actual_cost_to_date - p.planned_budget) / NULLIF(p.planned_budget, 0)) * 100,
        2
    )
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET estimate_at_completion =
    ROUND(
        p.planned_budget / NULLIF(
            (p.planned_budget / NULLIF(p.actual_cost_to_date, 0)), 0
        ),
        2
    )
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics
SET snapshot_date = CURRENT_DATE;

INSERT INTO kpi_metrics (project_id, snapshot_date)
SELECT project_id, CURRENT_DATE
FROM projects
WHERE project_id NOT IN (SELECT project_id FROM kpi_metrics);

SELECT project_id,
       planned_duration_days,
       actual_duration_days,
       spi,
       cpi,
       budget_utilization_pct,
       cost_overrun_pct
FROM kpi_metrics;

ALTER TABLE kpi_metrics
DROP COLUMN IF EXISTS planned_duration_days,
DROP COLUMN IF EXISTS actual_duration_days,
DROP COLUMN IF EXISTS plan_to_start_ratio,
DROP COLUMN IF EXISTS on_time_task_pct,
DROP COLUMN IF EXISTS critical_path_delay_days,
DROP COLUMN IF EXISTS spi,
DROP COLUMN IF EXISTS cost_variance,
DROP COLUMN IF EXISTS cpi,
DROP COLUMN IF EXISTS budget_utilization_pct,
DROP COLUMN IF EXISTS cost_overrun_pct,
DROP COLUMN IF EXISTS estimate_at_completion;

ALTER TABLE kpi_metrics
ADD COLUMN planned_duration_days INT,
ADD COLUMN actual_duration_days INT,
ADD COLUMN plan_to_start_ratio NUMERIC(6,2),
ADD COLUMN critical_path_delay_days INT,
ADD COLUMN spi NUMERIC(6,2),
ADD COLUMN cost_variance NUMERIC(12,2),
ADD COLUMN cpi NUMERIC(6,2),
ADD COLUMN budget_utilization_pct NUMERIC(6,2),
ADD COLUMN cost_overrun_pct NUMERIC(6,2),
ADD COLUMN estimate_at_completion NUMERIC(14,2);

select * from kpi_metrics km ;



ALTER TABLE kpi_metrics
DROP CONSTRAINT IF EXISTS kpi_metrics_snapshot_date_key;

ALTER TABLE kpi_metrics
DROP COLUMN snapshot_date;

ALTER TABLE kpi_metrics
ADD CONSTRAINT kpi_metrics_project_id_key UNIQUE (project_id);

INSERT INTO kpi_metrics (project_id)
SELECT project_id
FROM projects
WHERE project_id NOT IN (
    SELECT project_id FROM kpi_metrics
);

SELECT * FROM kpi_metrics;

DROP TABLE IF EXISTS kpi_metrics CASCADE;

CREATE TABLE kpi_metrics (
    project_id VARCHAR PRIMARY KEY REFERENCES projects(project_id),

    planned_duration_days INT,
    actual_duration_days INT,
    plan_to_start_ratio NUMERIC(6,2),
    on_time_task_pct NUMERIC(5,2),

    critical_path_delay_days INT,
    spi NUMERIC(6,2),

    cost_variance NUMERIC(12,2),
    cpi NUMERIC(6,2),
    budget_utilization_pct NUMERIC(6,2),
    cost_overrun_pct NUMERIC(6,2),

    estimate_at_completion NUMERIC(14,2),

    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO kpi_metrics (project_id)
SELECT project_id
FROM projects;

SELECT * FROM kpi_metrics;

UPDATE kpi_metrics k
SET planned_duration_days =
    (p.planned_end_date - p.planned_start_date)
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET actual_duration_days =
    (p.actual_end_date - p.actual_start_date)
FROM projects p
WHERE k.project_id = p.project_id
AND p.actual_end_date IS NOT NULL;

UPDATE kpi_metrics k
SET plan_to_start_ratio =
    ROUND(
        (p.planned_end_date - p.planned_start_date)::numeric /
        NULLIF((p.actual_end_date - p.actual_start_date), 0),
        2
    )
FROM projects p
WHERE k.project_id = p.project_id
AND p.actual_end_date IS NOT NULL;

UPDATE kpi_metrics k
SET critical_path_delay_days =
    (p.actual_end_date - p.actual_start_date) -
    (p.planned_end_date - p.planned_start_date)
FROM projects p
WHERE k.project_id = p.project_id
AND p.actual_end_date IS NOT NULL;

UPDATE kpi_metrics k
SET spi =
    ROUND(
        (p.planned_end_date - p.planned_start_date)::numeric /
        NULLIF((p.actual_end_date - p.actual_start_date), 0),
        2
    )
FROM projects p
WHERE k.project_id = p.project_id
AND p.actual_end_date IS NOT NULL;

UPDATE kpi_metrics k
SET cost_variance =
    (p.planned_budget - p.actual_cost_to_date)
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET cpi =
    ROUND(p.planned_budget / NULLIF(p.actual_cost_to_date, 0), 2)
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET budget_utilization_pct =
    ROUND((p.actual_cost_to_date / NULLIF(p.planned_budget, 0)) * 100, 2)
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET cost_overrun_pct =
    ROUND(((p.actual_cost_to_date - p.planned_budget) / NULLIF(p.planned_budget, 0)) * 100, 2)
FROM projects p
WHERE k.project_id = p.project_id;

UPDATE kpi_metrics k
SET estimate_at_completion =
    ROUND(p.planned_budget / NULLIF(
        (p.planned_budget / NULLIF(p.actual_cost_to_date, 0)), 0
    ), 2)
FROM projects p
WHERE k.project_id = p.project_id;

select * from kpi_metrics km ;

ALTER TABLE kpi_metrics
ADD COLUMN utilization_pct NUMERIC(6,2),
ADD COLUMN overallocated_pct NUMERIC(6,2),
ADD COLUMN underutilized_pct NUMERIC(6,2),
ADD COLUMN total_idle_hours NUMERIC(12,2),
ADD COLUMN avg_overtime_hours NUMERIC(6,2),
ADD COLUMN burnout_high_pct NUMERIC(6,2),
ADD COLUMN on_time_delivery_pct NUMERIC(6,2),
ADD COLUMN avg_delay_days NUMERIC(6,2),
ADD COLUMN attrition_rate_pct NUMERIC(6,2),
ADD COLUMN project_health_avg NUMERIC(6,2);

UPDATE kpi_metrics k
SET utilization_pct = sub.util_pct
FROM (
    SELECT project_id,
           ROUND(SUM(allocated_hours) / NULLIF(SUM(allocated_hours + idle_hours),0) * 100, 2) AS util_pct
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics k
SET overallocated_pct = sub.pct
FROM (
    SELECT project_id,
           ROUND(100.0 * COUNT(*) FILTER (WHERE allocation_status = 'Overallocated') / NULLIF(COUNT(*),0), 2) AS pct
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics k
SET underutilized_pct = sub.pct
FROM (
    SELECT project_id,
           ROUND(100.0 * COUNT(*) FILTER (WHERE allocation_status = 'Bench') / NULLIF(COUNT(*),0), 2) AS pct
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics k
SET total_idle_hours = sub.total_idle
FROM (
    SELECT project_id, SUM(idle_hours) AS total_idle
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics k
SET avg_overtime_hours = sub.avg_ot
FROM (
    SELECT project_id, ROUND(AVG(overtime_hours),2) AS avg_ot
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics k
SET burnout_high_pct = sub.pct
FROM (
    SELECT project_id,
           ROUND(100.0 * COUNT(*) FILTER (WHERE burnout_risk_level = 'High') / NULLIF(COUNT(*),0), 2) AS pct
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics k
SET on_time_delivery_pct = sub.pct
FROM (
    SELECT project_id,
           ROUND(100.0 * COUNT(*) FILTER (WHERE delay_days = 0) / NULLIF(COUNT(*),0), 2) AS pct
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics k
SET avg_delay_days = sub.avg_delay
FROM (
    SELECT project_id, ROUND(AVG(delay_days),2) AS avg_delay
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics k
SET attrition_rate_pct = sub.pct
FROM (
    SELECT a.project_id,
           ROUND(100.0 * COUNT(*) FILTER (WHERE e.left_organization = 'Yes') / NULLIF(COUNT(*),0), 2) AS pct
    FROM allocations a
    JOIN employees e ON a.employee_id = e.employee_id
    GROUP BY a.project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE kpi_metrics
SET project_health_avg =
ROUND((
    COALESCE(utilization_pct,0) * 0.25 +
    COALESCE(on_time_delivery_pct,0) * 0.25 +
    COALESCE(100 - cost_overrun_pct,0) * 0.25 +
    COALESCE(100 - burnout_high_pct,0) * 0.25
), 2);

SELECT * FROM kpi_metrics;

ALTER TABLE kpi_metrics
DROP COLUMN IF EXISTS on_time_task_pct;

SELECT 
    employee_id,
    allocated_hours,
    idle_hours
FROM allocations
LIMIT 10;

UPDATE kpi_metrics k
SET utilization_pct = sub.utilization_pct
FROM (
    SELECT 
        project_id,
        ROUND(
            100.0 * SUM(allocated_hours) / 
            NULLIF(SUM(allocated_hours + idle_hours), 0),
            2
        ) AS utilization_pct
    FROM allocations
    GROUP BY project_id
) sub
WHERE k.project_id = sub.project_id;

UPDATE projects
SET actual_end_date = planned_end_date + (random() * 20 - 10) * INTERVAL '1 day'
WHERE actual_end_date IS NOT NULL;

UPDATE projects
SET actual_end_date = planned_end_date + 
    ((random() * 40) - 20) * INTERVAL '1 day'
WHERE actual_end_date IS NOT NULL;

UPDATE projects
SET actual_cost_to_date = planned_budget * (0.6 + random() * 1.2);

select * from allocations a ;

SELECT 
  employee_id,
  project_id,
  onboarded_date,
  allocated_hours,
  allocation_ratio,
  overtime_hours,
  delay_days
FROM allocations
WHERE employee_id = 'E00016' AND project_id = 'P012';

UPDATE employees
SET left_organization = INITCAP(LOWER(TRIM(left_organization)));

UPDATE allocations
SET is_active_employee = INITCAP(LOWER(TRIM(is_active_employee)));

UPDATE allocations
SET requirement_needed = INITCAP(LOWER(TRIM(requirement_needed)));

UPDATE projects
SET project_status = INITCAP(LOWER(TRIM(project_status)));


UPDATE allocations a
SET
    idle_hours = GREATEST(e.available_hours - a.allocated_hours, 0),
    overtime_hours = GREATEST(a.allocated_hours - e.available_hours, 0),
    allocation_ratio = ROUND(a.allocated_hours::NUMERIC / NULLIF(e.available_hours, 0), 2),
    resource_utilization_efficiency = ROUND(LEAST(a.allocated_hours::NUMERIC / NULLIF(e.available_hours, 0), 1), 2),
    allocation_status = CASE
        WHEN a.allocated_hours = 0 THEN 'Bench'
        WHEN a.allocated_hours <= e.available_hours THEN 'Allocated'
        ELSE 'Overallocated'
    END,
    burnout_risk_level = CASE
        WHEN a.overtime_hours > 5 OR a.consecutive_working_days > 10 THEN 'High'
        WHEN a.overtime_hours > 2 OR a.consecutive_working_days > 6 THEN 'Medium'
        ELSE 'Low'
    END
FROM employees e
WHERE a.employee_id = e.employee_id;

ALTER TABLE allocations
ADD CONSTRAINT chk_alloc_nonneg CHECK (allocated_hours >= 0),
ADD CONSTRAINT chk_ratio_range CHECK (allocation_ratio BETWEEN 0 AND 2),
ADD CONSTRAINT chk_idle_nonneg CHECK (idle_hours >= 0),
ADD CONSTRAINT chk_overtime_nonneg CHECK (overtime_hours >= 0);

ALTER TABLE employees
ADD CONSTRAINT chk_daily_le_available CHECK (daily_hours_spent <= available_hours);

CREATE OR REPLACE FUNCTION calc_allocation_metrics()
RETURNS TRIGGER AS $$
DECLARE
    v_available INT;
BEGIN
    SELECT available_hours INTO v_available
    FROM employees WHERE employee_id = NEW.employee_id;

    IF v_available IS NULL OR v_available = 0 THEN
        v_available := 1;
    END IF;

    NEW.idle_hours := GREATEST(v_available - NEW.allocated_hours, 0);
    NEW.overtime_hours := GREATEST(NEW.allocated_hours - v_available, 0);

    NEW.allocation_ratio := ROUND(NEW.allocated_hours::NUMERIC / v_available, 2);
    NEW.resource_utilization_efficiency := ROUND(LEAST(NEW.allocated_hours::NUMERIC / v_available, 1), 2);

    IF NEW.allocated_hours = 0 THEN
        NEW.allocation_status := 'Bench';
    ELSIF NEW.allocated_hours <= v_available THEN
        NEW.allocation_status := 'Allocated';
    ELSE
        NEW.allocation_status := 'Overallocated';
    END IF;

    IF NEW.overtime_hours > 5 OR NEW.consecutive_working_days > 10 THEN
        NEW.burnout_risk_level := 'High';
    ELSIF NEW.overtime_hours > 2 OR NEW.consecutive_working_days > 6 THEN
        NEW.burnout_risk_level := 'Medium';
    ELSE
        NEW.burnout_risk_level := 'Low';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calc_alloc_metrics
BEFORE INSERT OR UPDATE
ON allocations
FOR EACH ROW
EXECUTE FUNCTION calc_allocation_metrics();

SELECT
    employee_id,
    project_id,
    allocated_hours,
    idle_hours,
    overtime_hours,
    allocation_ratio,
    allocation_status,
    resource_utilization_efficiency,
    burnout_risk_level
FROM allocations
ORDER BY employee_id, project_id;

UPDATE allocations a
SET
    idle_hours = GREATEST(e.available_hours - a.allocated_hours, 0),
    overtime_hours = GREATEST(a.allocated_hours - e.available_hours, 0),
    allocation_ratio = ROUND(a.allocated_hours::NUMERIC / NULLIF(e.available_hours, 0), 2),
    resource_utilization_efficiency = ROUND(LEAST(a.allocated_hours::NUMERIC / NULLIF(e.available_hours, 0), 1), 2),
    allocation_status = CASE
        WHEN a.allocated_hours = 0 THEN 'Bench'
        WHEN a.allocated_hours <= e.available_hours THEN 'Allocated'
        ELSE 'Overallocated'
    END,
    burnout_risk_level = CASE
        WHEN GREATEST(a.allocated_hours - e.available_hours, 0) > 20 THEN 'High'
        WHEN GREATEST(a.allocated_hours - e.available_hours, 0) BETWEEN 5 AND 20 THEN 'Medium'
        ELSE 'Low'
    END
FROM employees e
WHERE a.employee_id = e.employee_id;

SELECT
    a.employee_id,
    a.project_id,
    a.allocated_hours,
    e.available_hours,
    a.idle_hours,
    a.overtime_hours,
    a.allocation_ratio,
    a.allocation_status,
    a.resource_utilization_efficiency,
    a.burnout_risk_level
FROM allocations a
JOIN employees e ON a.employee_id = e.employee_id
LIMIT 20;

UPDATE allocations
SET burnout_risk_level = CASE
    WHEN overtime_hours > 20 THEN 'High'
    WHEN overtime_hours BETWEEN 5 AND 20 THEN 'Medium'
    ELSE 'Low'
END;

CREATE OR REPLACE FUNCTION calc_allocation_metrics()
RETURNS TRIGGER AS $$
DECLARE
    v_available INT;
BEGIN
    SELECT available_hours INTO v_available
    FROM employees WHERE employee_id = NEW.employee_id;

    IF v_available IS NULL OR v_available = 0 THEN
        v_available := 168;
    END IF;

    NEW.idle_hours := GREATEST(v_available - NEW.allocated_hours, 0);
    NEW.overtime_hours := GREATEST(NEW.allocated_hours - v_available, 0);

    NEW.allocation_ratio := ROUND(NEW.allocated_hours::NUMERIC / v_available, 2);
    NEW.resource_utilization_efficiency := ROUND(LEAST(NEW.allocated_hours::NUMERIC / v_available, 1), 2);

    IF NEW.allocated_hours = 0 THEN
        NEW.allocation_status := 'Bench';
    ELSIF NEW.allocated_hours <= v_available THEN
        NEW.allocation_status := 'Allocated';
    ELSE
        NEW.allocation_status := 'Overallocated';
    END IF;

    -- 🔥 Burnout based ONLY on overtime
    IF NEW.overtime_hours > 20 THEN
        NEW.burnout_risk_level := 'High';
    ELSIF NEW.overtime_hours BETWEEN 5 AND 20 THEN
        NEW.burnout_risk_level := 'Medium';
    ELSE
        NEW.burnout_risk_level := 'Low';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

UPDATE allocations
SET burnout_risk_level = CASE
    WHEN overtime_hours > 20 THEN 'High'
    WHEN overtime_hours BETWEEN 5 AND 20 THEN 'Medium'
    ELSE 'Low'
END;

CREATE OR REPLACE FUNCTION calc_allocation_metrics()
RETURNS TRIGGER AS $$
DECLARE
    v_available INT;
BEGIN
    SELECT available_hours INTO v_available
    FROM employees WHERE employee_id = NEW.employee_id;

    IF v_available IS NULL OR v_available = 0 THEN
        v_available := 168; -- monthly default
    END IF;

    NEW.idle_hours := GREATEST(v_available - NEW.allocated_hours, 0);
    NEW.overtime_hours := GREATEST(NEW.allocated_hours - v_available, 0);

    NEW.allocation_ratio := ROUND(NEW.allocated_hours::NUMERIC / v_available, 2);
    NEW.resource_utilization_efficiency := ROUND(LEAST(NEW.allocated_hours::NUMERIC / v_available, 1), 2);

    IF NEW.allocated_hours = 0 THEN
        NEW.allocation_status := 'Bench';
    ELSIF NEW.allocated_hours <= v_available THEN
        NEW.allocation_status := 'Allocated';
    ELSE
        NEW.allocation_status := 'Overallocated';
    END IF;

    -- ✅ Burnout based ONLY on overtime
    IF NEW.overtime_hours > 20 THEN
        NEW.burnout_risk_level := 'High';
    ELSIF NEW.overtime_hours BETWEEN 5 AND 20 THEN
        NEW.burnout_risk_level := 'Medium';
    ELSE
        NEW.burnout_risk_level := 'Low';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calc_alloc_metrics
BEFORE INSERT OR UPDATE
ON allocations
FOR EACH ROW
EXECUTE FUNCTION calc_allocation_metrics();

UPDATE allocations
SET allocated_hours = allocated_hours;

SELECT employee_id, project_id, allocated_hours,
       idle_hours, overtime_hours, allocation_ratio,
       allocation_status, resource_utilization_efficiency,
       burnout_risk_level
FROM allocations
LIMIT 20;

ALTER TABLE allocations
ADD CONSTRAINT chk_alloc_vs_capacity
CHECK (allocated_hours >= 0);

-- Allow only up to 150% utilization
ALTER TABLE allocations
ADD CONSTRAINT chk_alloc_reasonable
CHECK (allocation_ratio <= 1.5);

ALTER TABLE allocations
ADD CONSTRAINT chk_allocation_status
CHECK (allocation_status IN ('Allocated', 'Bench', 'Overallocated'));

ALTER TABLE allocations
ADD CONSTRAINT chk_burnout_risk
CHECK (burnout_risk_level IN ('Low', 'Medium', 'High'));

ALTER TABLE allocations
ADD CONSTRAINT chk_active_flag
CHECK (is_active_employee IN ('Yes', 'No'));

ALTER TABLE allocations
ADD CONSTRAINT chk_req_needed
CHECK (requirement_needed IN ('Yes', 'No'));

CREATE UNIQUE INDEX uniq_active_allocation
ON allocations(employee_id, project_id)
WHERE offboarded_date IS NULL;

CREATE OR REPLACE FUNCTION prevent_overlap()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM allocations a
        WHERE a.employee_id = NEW.employee_id
          AND a.project_id <> NEW.project_id
          AND (NEW.onboarded_date <= COALESCE(a.offboarded_date, '9999-12-31'))
          AND (COALESCE(NEW.offboarded_date, '9999-12-31') >= a.onboarded_date)
    ) THEN
        RAISE EXCEPTION 'Employee already allocated to another project in this period';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_overlap ON allocations;

CREATE TRIGGER trg_prevent_overlap
BEFORE INSERT OR UPDATE ON allocations
FOR EACH ROW EXECUTE FUNCTION prevent_overlap();

ALTER TABLE employees
ADD CONSTRAINT chk_hours_valid CHECK (daily_hours_spent BETWEEN 1 AND 24),
ADD CONSTRAINT chk_available_hours CHECK (available_hours BETWEEN 40 AND 240);

ALTER TABLE employees
ADD CONSTRAINT chk_left_org
CHECK (left_organization IN ('Yes', 'No'));

-- People with impossible utilization
SELECT * FROM allocations WHERE allocation_ratio > 1.5;

-- Bench but allocated hours not zero
SELECT * FROM allocations
WHERE allocation_status = 'Bench' AND allocated_hours > 0;

-- Burnout mismatch
SELECT * FROM allocations
WHERE overtime_hours = 0 AND burnout_risk_level <> 'Low';

ALTER TABLE allocations
ADD CONSTRAINT chk_hours_non_negative 
CHECK (allocated_hours >= 0 AND idle_hours >= 0 AND overtime_hours >= 0);

ALTER TABLE allocations
ADD CONSTRAINT chk_status_valid 
CHECK (allocation_status IN ('Allocated', 'Bench', 'Overallocated'));


ALTER TABLE employees
ADD CONSTRAINT chk_daily_hours 
CHECK (daily_hours_spent BETWEEN 1 AND 24);

ALTER TABLE allocations
ADD CONSTRAINT chk_hours_non_negative 
CHECK (allocated_hours >= 0 AND idle_hours >= 0 AND overtime_hours >= 0);

ALTER TABLE allocations
ADD CONSTRAINT chk_ratio_range 
CHECK (allocation_ratio BETWEEN 0 AND 1);

ALTER TABLE allocations
ADD CONSTRAINT chk_status_valid 
CHECK (allocation_status IN ('Allocated', 'Bench', 'Overallocated'));

UPDATE allocations SET is_active_employee = 'Yes' WHERE is_active_employee ILIKE 'active';
UPDATE allocations SET is_active_employee = 'No' WHERE is_active_employee ILIKE 'inactive';

UPDATE projects SET project_status = INITCAP(project_status);
UPDATE employees SET left_organization = INITCAP(left_organization);

INSERT INTO kpi_metrics (project_id, utilization_pct, avg_delay_days, total_idle_hours)
SELECT 
    project_id,
    AVG(allocation_ratio) * 100,
    AVG(delay_days),
    SUM(idle_hours)
FROM allocations
GROUP BY project_id
ON CONFLICT (project_id) DO UPDATE
SET utilization_pct = EXCLUDED.utilization_pct,
    avg_delay_days = EXCLUDED.avg_delay_days,
    total_idle_hours = EXCLUDED.total_idle_hours;

CREATE OR REPLACE FUNCTION auto_calc_allocations()
RETURNS TRIGGER AS $$
DECLARE
    emp_hours INT;
    ratio_val NUMERIC;
BEGIN
    SELECT available_hours INTO emp_hours 
    FROM employees 
    WHERE employee_id = NEW.employee_id;

    -- Idle hours
    NEW.idle_hours := GREATEST(emp_hours - NEW.allocated_hours, 0);

    -- Allocation ratio
    IF emp_hours > 0 THEN
        ratio_val := NEW.allocated_hours::NUMERIC / emp_hours;
    ELSE
        ratio_val := 0;
    END IF;

    NEW.allocation_ratio := ROUND(ratio_val, 2);

    -- Allocation status
    IF ratio_val = 0 THEN
        NEW.allocation_status := 'Bench';
    ELSIF ratio_val > 1 THEN
        NEW.allocation_status := 'Overallocated';
    ELSE
        NEW.allocation_status := 'Allocated';
    END IF;

    -- Burnout risk
    IF NEW.overtime_hours > 20 OR NEW.consecutive_working_days > 14 THEN
        NEW.burnout_risk_level := 'High';
    ELSIF NEW.overtime_hours > 10 THEN
        NEW.burnout_risk_level := 'Medium';
    ELSE
        NEW.burnout_risk_level := 'Low';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_calc_alloc
BEFORE INSERT OR UPDATE ON allocations
FOR EACH ROW
EXECUTE FUNCTION auto_calc_allocations();

ALTER TABLE allocations ADD COLUMN approval_status VARCHAR DEFAULT 'Approved';

SELECT conname, pg_get_constraintdef(c.oid)
FROM pg_constraint c
JOIN pg_class t ON c.conrelid = t.oid
WHERE t.relname = 'employees'
  AND conname = 'chk_available_hours';

CREATE OR REPLACE FUNCTION enforce_active_flag()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.offboarded_date IS NOT NULL THEN
        NEW.is_active_employee := 'No';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_enforce_active_flag ON allocations;

CREATE TRIGGER trg_enforce_active_flag
BEFORE INSERT OR UPDATE ON allocations
FOR EACH ROW
EXECUTE FUNCTION enforce_active_flag();

UPDATE allocations
SET is_active_employee = 'No'
WHERE offboarded_date IS NOT NULL;

UPDATE employees
SET available_hours = 10;

ALTER TABLE employees DROP CONSTRAINT chk_available_hours;

SELECT COUNT(DISTINCT e.employee_id) AS idle_people
FROM employees e
LEFT JOIN allocations a
  ON e.employee_id = a.employee_id
  AND a.is_active_employee = 'Yes'
WHERE e.left_organization = 'No'
GROUP BY e.employee_id
HAVING COALESCE(SUM(a.allocated_hours), 0) = 0;

UPDATE employees e
SET daily_hours_spent = COALESCE((
    SELECT SUM(a.allocated_hours)
    FROM allocations a
    WHERE a.employee_id = e.employee_id
      AND a.is_active_employee = 'Yes'
      AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE)
), 0);

UPDATE allocations a
SET idle_hours = GREATEST(
    10 - COALESCE((
        SELECT SUM(a2.allocated_hours)
        FROM allocations a2
        WHERE a2.employee_id = a.employee_id
          AND a2.is_active_employee = 'Yes'
          AND (a2.offboarded_date IS NULL OR a2.offboarded_date >= CURRENT_DATE)
    ), 0),
    0
)
WHERE a.is_active_employee = 'Yes'
  AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE);

SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conname = 'chk_alloc_reasonable';

ALTER TABLE allocations DROP CONSTRAINT chk_alloc_reasonable;

ALTER TABLE allocations
ADD CONSTRAINT chk_alloc_reasonable
CHECK (
    allocated_hours >= 0
    AND allocated_hours <= 10
);

SELECT employee_id, project_id, onboarded_date, allocated_hours
FROM allocations
WHERE allocated_hours < 0
   OR allocated_hours > 10;

UPDATE allocations
SET allocated_hours = ROUND(allocated_hours / 20.0, 2)
WHERE allocated_hours > 10;


ALTER TABLE employees
DROP CONSTRAINT chk_daily_hours;

ALTER TABLE employees
ADD CONSTRAINT chk_daily_hours
CHECK (
    daily_hours_spent >= 0
    AND daily_hours_spent <= 10
);

UPDATE employees e
SET daily_hours_spent = COALESCE((
    SELECT SUM(a.allocated_hours)
    FROM allocations a
    WHERE a.employee_id = e.employee_id
      AND a.is_active_employee = 'Yes'
      AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE)
), 0);

UPDATE allocations a
SET idle_hours = GREATEST(
    10 - (
        SELECT COALESCE(SUM(a2.allocated_hours), 0)
        FROM allocations a2
        WHERE a2.employee_id = a.employee_id
          AND a2.is_active_employee = 'Yes'
          AND (a2.offboarded_date IS NULL OR a2.offboarded_date >= CURRENT_DATE)
    ),
    0
);

UPDATE employees e
SET daily_hours_spent = COALESCE((
    SELECT SUM(a.allocated_hours)
    FROM allocations a
    WHERE a.employee_id = e.employee_id
      AND a.is_active_employee = 'Yes'
      AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE)
), 0);

ALTER TABLE employees
DROP CONSTRAINT chk_hours_valid;

ALTER TABLE employees
ADD CONSTRAINT chk_hours_valid
CHECK (
    daily_hours_spent >= 0
    AND daily_hours_spent <= 10
);

UPDATE employees e
SET daily_hours_spent = COALESCE((
    SELECT SUM(a.allocated_hours)
    FROM allocations a
    WHERE a.employee_id = e.employee_id
      AND a.is_active_employee = 'Yes'
      AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE)
), 0);

UPDATE allocations a
SET offboarded_date = CURRENT_DATE,
    is_active_employee = 'No'
FROM employees e
WHERE a.employee_id = e.employee_id
  AND e.left_organization = 'Yes'
  AND (a.offboarded_date IS NULL OR a.is_active_employee = 'Yes');

CREATE OR REPLACE FUNCTION enforce_left_employee_rules()
RETURNS TRIGGER AS $$
BEGIN
    -- If employee has left org → force inactive + offboarded
    IF EXISTS (
        SELECT 1 FROM employees e
        WHERE e.employee_id = NEW.employee_id
          AND e.left_organization = 'Yes'
    ) THEN
        NEW.is_active_employee := 'No';

        IF NEW.offboarded_date IS NULL THEN
            NEW.offboarded_date := CURRENT_DATE;
        END IF;
    END IF;

    RETURN NEW;
END;


DROP TRIGGER IF EXISTS trg_left_employee_rules ON allocations;

CREATE TRIGGER trg_left_employee_rules
BEFORE INSERT OR UPDATE ON allocations
FOR EACH ROW
EXECUTE FUNCTION enforce_left_employee_rules();


ALTER TABLE employees
DROP CONSTRAINT IF EXISTS chk_daily_hours_spent;

ALTER TABLE employees
ADD CONSTRAINT chk_daily_hours_spent
CHECK (daily_hours_spent BETWEEN 0 AND 24);

ALTER TABLE allocations DROP CONSTRAINT chk_alloc_reasonable;

ALTER TABLE allocations
ADD CONSTRAINT chk_alloc_reasonable
CHECK (allocated_hours >= 0);

CREATE OR REPLACE FUNCTION trg_calc_allocation_metrics()
RETURNS TRIGGER AS $$
BEGIN
    -- Overtime calculation
    NEW.overtime_hours := GREATEST(NEW.allocated_hours - 10, 0);

    -- Allocation status
    IF NEW.allocated_hours > 10 THEN
        NEW.allocation_status := 'Overallocated';
    ELSIF NEW.allocated_hours = 0 THEN
        NEW.allocation_status := 'Idle';
    ELSE
        NEW.allocation_status := 'Allocated';
    END IF;

    -- Ratios
    NEW.allocation_ratio := ROUND(NEW.allocated_hours / 10.0, 2);
    NEW.resource_utilization_efficiency := ROUND(NEW.allocated_hours / 10.0, 2);

    -- Optional: Burnout Risk (simple logic)
    IF NEW.allocated_hours >= 12 THEN
        NEW.burnout_risk_level := 'High';
    ELSIF NEW.allocated_hours > 10 THEN
        NEW.burnout_risk_level := 'Medium';
    ELSE
        NEW.burnout_risk_level := 'Low';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS before_allocations_metrics ON allocations;

CREATE TRIGGER before_allocations_metrics
BEFORE INSERT OR UPDATE ON allocations
FOR EACH ROW
EXECUTE FUNCTION trg_calc_allocation_metrics();

ALTER TABLE allocations DROP CONSTRAINT IF EXISTS chk_alloc_reasonable;

ALTER TABLE allocations
ADD CONSTRAINT chk_alloc_reasonable
CHECK (allocated_hours >= 0 AND allocated_hours <= 14);

UPDATE allocations
SET allocated_hours = allocated_hours;

SELECT tgname, tgrelid::regclass
FROM pg_trigger
WHERE tgrelid = 'allocations'::regclass
  AND NOT tgisinternal;

SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'allocations'::regclass;

SELECT employee_id, project_id, onboarded_date, pg_typeof(onboarded_date)
FROM allocations
WHERE employee_id = 'E02626' AND project_id = 'P001';

WHERE employee_id=:eid 
  AND project_id=:pid 
  AND onboarded_date::date = :onb;

SELECT tgname, tgenabled
FROM pg_trigger
WHERE tgrelid = 'allocations'::regclass
  AND NOT tgisinternal;

UPDATE allocations
SET allocated_hours = 11
WHERE employee_id = 'E02626'
  AND project_id = 'P001'
  AND onboarded_date = '2026-02-26';

SELECT allocated_hours, overtime_hours, allocation_status
FROM allocations
WHERE employee_id = 'E02626'
  AND project_id = 'P001'
  AND onboarded_date = '2026-02-26';

SELECT a.employee_id, a.project_id, a.onboarded_date, a.allocated_hours,
SUM(a.allocated_hours) OVER (
        PARTITION BY a.employee_id, a.onboarded_date
    ) AS total_daily_hours,
    CASE 
        WHEN SUM(a.allocated_hours) OVER (
            PARTITION BY a.employee_id, a.onboarded_date
        ) > 10 THEN 'Overallocated'
        WHEN SUM(a.allocated_hours) OVER (
            PARTITION BY a.employee_id, a.onboarded_date
        ) = 0 THEN 'Bench'
        ELSE 'Allocated'
    END AS employee_day_status,
    GREATEST(
        SUM(a.allocated_hours) OVER (
            PARTITION BY a.employee_id, a.onboarded_date
        ) - 10,
        0
    ) AS employee_day_overtime
    FROM allocations a
ORDER BY a.employee_id, a.onboarded_date;

select a.employee_id, a.project_id, a.onboarded_date, a.allocated_hours,SUM(
        CASE 
            WHEN a.is_active_employee = 'Yes'
             AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
            THEN a.allocated_hours
            ELSE 0
        END
    ) OVER (PARTITION BY a.employee_id, a.onboarded_date) AS total_daily_hours
FROM allocations a
ORDER BY a.employee_id, a.onboarded_date;

select a.employee_id, a.project_id, a.onboarded_date, a.allocated_hours,
CASE
        WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) > 10 THEN 'Overallocated'
WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) = 0 THEN 'Bench'
ELSE 'Allocated'
    END AS employee_day_status FROM allocations a
ORDER BY a.employee_id, a.onboarded_date;

SELECT
    a.employee_id,
    a.project_id,
    a.onboarded_date,
    a.allocated_hours,
GREATEST(
        SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) - 10,
        0
    ) AS employee_day_overtime
FROM allocations a
ORDER BY a.employee_id, a.onboarded_date;

SELECT
    a.employee_id,
    a.project_id,
    a.onboarded_date,
    a.allocated_hours,
GREATEST(
        SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) - 10,
        0
    ) AS employee_day_overtime
FROM allocations a
ORDER BY a.employee_id, a.onboarded_date;

SELECT
    p.project_id,
    p.project_name,
    p.actual_start_date,
    p.actual_end_date,
LEAST(
        ROUND(
            (CURRENT_DATE - p.actual_start_date)::numeric /
            NULLIF((p.actual_end_date - p.actual_start_date), 0) * 100,
            2
        ),
        100
    ) AS progress_percentage
FROM projects p;

SELECT
    a.*,
    e.department,
    e.designation,
    p.project_name,
    p.project_status,
SUM(
        CASE 
            WHEN a.is_active_employee = 'Yes'
             AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
            THEN a.allocated_hours
            ELSE 0
        END
    ) OVER (PARTITION BY a.employee_id, a.onboarded_date) AS total_daily_hours,
    CASE
        WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) > 10 THEN 'Overallocated'
        WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) = 0 THEN 'Bench'
        ELSE 'Allocated'
    END AS employee_day_status,
GREATEST(
        SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) - 10,
        0
    ) AS employee_day_overtime,
CASE
    WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) > 10 THEN 'High'
        WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) BETWEEN 9 AND 10 THEN 'Medium'
        ELSE 'Low'
    END AS burnout_risk_level
FROM allocations a
LEFT JOIN employees e ON a.employee_id = e.employee_id
LEFT JOIN projects p ON a.project_id = p.project_id
ORDER BY a.employee_id, a.onboarded_date, a.project_id;


SELECT
    employee_id,
    onboarded_date,
    SUM(
        CASE 
            WHEN is_active_employee = 'Yes'
                 AND (offboarded_date IS NULL OR offboarded_date > onboarded_date)
            THEN allocated_hours
            ELSE 0
        END
    ) AS active_hours,
    GREATEST(
        10 - SUM(
            CASE 
                WHEN is_active_employee = 'Yes'
                     AND (offboarded_date IS NULL OR offboarded_date > onboarded_date)
                THEN allocated_hours
                ELSE 0
            END
        ),
        0
    ) AS idle_hours
FROM allocations
GROUP BY employee_id, onboarded_date
ORDER BY employee_id, onboarded_date;

SELECT a.*,e.level,e.primary_skill,e.department,e.designation,p.project_name,p.project_status,p.actual_start_date,p.actual_end_date,SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date) AS total_daily_hours,CASE WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)>10 THEN 'Overallocated' WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)=0 THEN 'Bench' ELSE 'Allocated' END AS employee_day_status,GREATEST(SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)-10,0) AS employee_day_overtime,GREATEST(10-SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date),0) AS employee_day_idle_hours,ROUND(LEAST(SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)/10.0,1.4),2) AS resource_utilization_efficiency_live FROM allocations a LEFT JOIN employees e ON a.employee_id=e.employee_id LEFT JOIN projects p ON a.project_id=p.project_id ORDER BY a.employee_id,a.onboarded_date,a.project_id;

SELECT a.*,e.level,e.primary_skill,e.department,e.designation,p.project_name,p.project_status,SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date) AS total_daily_hours,CASE WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)>10 THEN 'Overallocated' WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)=0 THEN 'Bench' ELSE 'Allocated' END AS employee_day_status,GREATEST(SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)-10,0) AS employee_day_overtime,GREATEST(10-SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date),0) AS employee_day_idle_hours,ROUND(GREATEST(LEAST(((CURRENT_DATE-p.actual_start_date)::numeric/NULLIF((p.actual_end_date-p.actual_start_date),0)*100)-(COALESCE(a.delay_days,0)*1.5),100),0),2) AS progress_percentage_live FROM allocations a LEFT JOIN employees e ON a.employee_id=e.employee_id LEFT JOIN projects p ON a.project_id=p.project_id ORDER BY a.employee_id,a.onboarded_date,a.project_id;

SELECT a.*,e.level,e.primary_skill,e.department,e.designation,p.project_name,p.project_status,SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date) AS total_daily_hours,CASE WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)>10 THEN 'Overallocated' WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)=0 THEN 'Bench' ELSE 'Allocated' END AS employee_day_status,GREATEST(SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)-10,0) AS employee_day_overtime,GREATEST(10-SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date),0) AS employee_day_idle_hours,ROUND(GREATEST(LEAST(((CURRENT_DATE-p.actual_start_date)::numeric/NULLIF((p.actual_end_date-p.actual_start_date),0)*100)-(COALESCE(a.delay_days,0)*1.5),100),0),2) AS progress_percentage_live,ROUND(GREATEST(LEAST(SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)/10,1),0),2) AS resource_utilization_efficiency_live,CASE WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)>=12 THEN 'High' WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)>=9 THEN 'Medium' ELSE 'Low' END AS burnout_risk_level_live,COUNT(*) OVER (PARTITION BY a.employee_id ORDER BY a.onboarded_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS consecutive_working_days_live FROM allocations a LEFT JOIN employees e ON a.employee_id=e.employee_id LEFT JOIN projects p ON a.project_id=p.project_id ORDER BY a.employee_id,a.onboarded_date,a.project_id;

SELECT a.*,e.level,e.primary_skill,e.department,e.designation,p.project_name,p.project_status,SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date) AS total_daily_hours,CASE WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)>10 THEN 'Overallocated' WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)=0 THEN 'Bench' ELSE 'Allocated' END AS employee_day_status,GREATEST(SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)-10,0) AS employee_day_overtime,GREATEST(10-SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date),0) AS employee_day_idle_hours,ROUND(GREATEST(LEAST(((CURRENT_DATE-p.planned_start_date)::numeric/NULLIF((p.planned_end_date-p.planned_start_date),0)*100)-(COALESCE(a.delay_days,0)*2),100),0),2) AS progress_percentage_live,ROUND(GREATEST(LEAST(SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)/10,1),0),2) AS resource_utilization_efficiency_live,CASE WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)>=12 THEN 'High' WHEN SUM(CASE WHEN a.is_active_employee='Yes' AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date) THEN a.allocated_hours ELSE 0 END) OVER (PARTITION BY a.employee_id,a.onboarded_date)>=9 THEN 'Medium' ELSE 'Low' END AS burnout_risk_level_live,COUNT(*) OVER (PARTITION BY a.employee_id ORDER BY a.onboarded_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS consecutive_working_days_live FROM allocations a LEFT JOIN employees e ON a.employee_id=e.employee_id LEFT JOIN projects p ON a.project_id=p.project_id ORDER BY a.employee_id,a.onboarded_date,a.project_id;

SELECT 
    a.*,
    e.level,
    e.primary_skill,
    e.department,
    e.designation,
    p.project_name,
    p.project_status,
    SUM(
        CASE 
            WHEN a.is_active_employee = 'Yes'
                 AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
            THEN a.allocated_hours
            ELSE 0
        END
    ) OVER (
        PARTITION BY a.employee_id, a.onboarded_date
    ) AS total_daily_hours,
    CASE 
        WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                     AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) > 10 
        THEN 'Overallocated'
        WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                     AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) = 0 
        THEN 'Bench'
        ELSE 'Allocated'
    END AS employee_day_status,
    GREATEST(
        SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                     AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) - 10,
        0
    ) AS employee_day_overtime,
    GREATEST(
        10 - SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                     AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date),
        0
    ) AS employee_day_idle_hours,
    ROUND(
        LEAST(
            SUM(
                CASE 
                    WHEN a.is_active_employee = 'Yes'
                         AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                    THEN a.allocated_hours
                    ELSE 0
                END
            ) OVER (PARTITION BY a.employee_id, a.onboarded_date) / 10.0,
            1
        ),
        2
    ) AS resource_utilization_efficiency_live,
    CASE
        WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                     AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) >= 12 THEN 'High'
        WHEN SUM(
            CASE 
                WHEN a.is_active_employee = 'Yes'
                     AND (a.offboarded_date IS NULL OR a.offboarded_date > a.onboarded_date)
                THEN a.allocated_hours
                ELSE 0
            END
        ) OVER (PARTITION BY a.employee_id, a.onboarded_date) >= 9 THEN 'Medium'
        ELSE 'Low'
    END AS burnout_risk_level_live,
    COUNT(*) OVER (
        PARTITION BY a.employee_id
        ORDER BY a.onboarded_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS consecutive_working_days_live,
    ROUND(
        GREATEST(
            CASE 
                WHEN CURRENT_DATE > p.planned_end_date 
                THEN 100 - (COALESCE(a.delay_days, 0) * 2)

                ELSE (
                    (CURRENT_DATE - p.planned_start_date)::numeric /
                    NULLIF((p.planned_end_date - p.planned_start_date), 0)
                    * 100
                ) - (COALESCE(a.delay_days, 0) * 2)
            END,
            0
        ),
        2
    ) AS progress_percentage_live
FROM allocations a
LEFT JOIN employees e ON a.employee_id = e.employee_id
LEFT JOIN projects p ON a.project_id = p.project_id
ORDER BY a.employee_id, a.onboarded_date, a.project_id;

UPDATE allocations a
SET offboarded_date = CURRENT_DATE,
    is_active_employee = 'No'
FROM projects p
WHERE a.project_id = p.project_id
AND p.project_status IN ('Completed','On Hold')
AND a.is_active_employee = 'Yes';
CREATE OR REPLACE FUNCTION auto_offboard_on_project_close()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.project_status IN ('Completed','On Hold') THEN
        UPDATE allocations
        SET offboarded_date = CURRENT_DATE,
            is_active_employee = 'No'
        WHERE project_id = NEW.project_id
        AND is_active_employee = 'Yes';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW project_summary AS
SELECT 
    p.project_id,
    p.project_name,
    p.planned_budget,
    SUM(a.allocated_hours) AS total_allocated_hours,
    SUM(a.allocated_hours * 1000) AS actual_cost_to_date,
    p.planned_budget - SUM(a.allocated_hours * 1000) AS cost_variance
FROM projects p
LEFT JOIN allocations a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name, p.planned_budget;

SELECT
a.employee_id,
a.project_id,
p.project_name,
p.project_status,
a.onboarded_date,
a.offboarded_date,
a.allocated_hours,
a.delay_days,
e.department,
e.designation,
e.level,
e.primary_skill,
SUM(
CASE
WHEN a.is_active_employee='Yes'
AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date)
AND p.project_status='Active'
THEN a.allocated_hours
ELSE 0
END
) OVER (PARTITION BY a.employee_id,a.onboarded_date) AS total_daily_hours,
CASE
WHEN p.project_status IN ('Completed','On Hold') THEN 'Bench'
WHEN SUM(
CASE
WHEN a.is_active_employee='Yes'
AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date)
AND p.project_status='Active'
THEN a.allocated_hours
ELSE 0
END
) OVER (PARTITION BY a.employee_id,a.onboarded_date)>10 THEN 'Overallocated'
WHEN SUM(
CASE
WHEN a.is_active_employee='Yes'
AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date)
AND p.project_status='Active'
THEN a.allocated_hours
ELSE 0
END
) OVER (PARTITION BY a.employee_id,a.onboarded_date)=0 THEN 'Bench'
ELSE 'Allocated'
END AS allocation_status,
GREATEST(
SUM(
CASE
WHEN a.is_active_employee='Yes'
AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date)
AND p.project_status='Active'
THEN a.allocated_hours
ELSE 0
END
) OVER (PARTITION BY a.employee_id,a.onboarded_date)-10,
0
) AS overtime_hours,
GREATEST(
10-
SUM(
CASE
WHEN a.is_active_employee='Yes'
AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date)
AND p.project_status='Active'
THEN a.allocated_hours
ELSE 0
END
) OVER (PARTITION BY a.employee_id,a.onboarded_date),
0
) AS idle_hours,
ROUND(
LEAST(
SUM(
CASE
WHEN a.is_active_employee='Yes'
AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date)
AND p.project_status='Active'
THEN a.allocated_hours
ELSE 0
END
) OVER (PARTITION BY a.employee_id,a.onboarded_date)/10.0,
1.4
),
2
) AS resource_utilization_efficiency,
CASE
WHEN SUM(
CASE
WHEN a.is_active_employee='Yes'
AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date)
AND p.project_status='Active'
THEN a.allocated_hours
ELSE 0
END
) OVER (PARTITION BY a.employee_id,a.onboarded_date)>12 THEN 'High'
WHEN SUM(
CASE
WHEN a.is_active_employee='Yes'
AND (a.offboarded_date IS NULL OR a.offboarded_date>a.onboarded_date)
AND p.project_status='Active'
THEN a.allocated_hours
ELSE 0
END
) OVER (PARTITION BY a.employee_id,a.onboarded_date) BETWEEN 9 AND 12 THEN 'Medium'
ELSE 'Low'
END AS burnout_risk_level,
COUNT(
CASE
WHEN a.is_active_employee='Yes'
AND p.project_status='Active'
THEN 1
END
) OVER (
PARTITION BY a.employee_id
ORDER BY a.onboarded_date
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) AS consecutive_working_days,
CASE
WHEN p.actual_start_date IS NULL THEN 0
WHEN p.actual_end_date IS NOT NULL THEN 100
ELSE ROUND(
LEAST(
(CURRENT_DATE-p.actual_start_date)::NUMERIC/
NULLIF((p.planned_end_date-p.actual_start_date),0)*100,
100
),
2
)
END AS progress_percentage
FROM allocations a
LEFT JOIN employees e ON a.employee_id=e.employee_id
LEFT JOIN projects p ON a.project_id=p.project_id
ORDER BY a.employee_id,a.onboarded_date,a.project_id;


UPDATE projects
SET planned_budget = 
CASE 
WHEN project_name LIKE '%Migration%' THEN FLOOR(RANDOM()*10000000)+8000000
WHEN project_name LIKE '%ERP%' THEN FLOOR(RANDOM()*15000000)+12000000
WHEN project_name LIKE '%AI%' THEN FLOOR(RANDOM()*8000000)+4000000
ELSE FLOOR(RANDOM()*6000000)+3000000
END;

UPDATE projects
SET planned_budget = 
CASE 
WHEN project_name LIKE '%Migration%' THEN FLOOR(RANDOM()*10000000)+8000000
WHEN project_name LIKE '%ERP%' THEN FLOOR(RANDOM()*15000000)+12000000
WHEN project_name LIKE '%AI%' THEN FLOOR(RANDOM()*8000000)+4000000
ELSE FLOOR(RANDOM()*6000000)+3000000
END;

UPDATE projects
SET cost_variance = planned_budget - actual_cost_to_date;

UPDATE projects p
SET actual_cost_to_date = actual_cost_to_date + (delay_factor * 1000000)
FROM (
    SELECT project_id, SUM(delay_days) AS delay_factor
    FROM allocations
    GROUP BY project_id
) d
WHERE p.project_id = d.project_id;

UPDATE projects
SET actual_cost_to_date = planned_budget * (0.85 + RANDOM()*0.4);

UPDATE projects
SET planned_budget =
CASE
    WHEN project_name LIKE '%AI%' THEN FLOOR(RANDOM()*15000000)+15000000
    WHEN project_name LIKE '%ERP%' THEN FLOOR(RANDOM()*20000000)+10000000
    WHEN project_name LIKE '%Migration%' THEN FLOOR(RANDOM()*12000000)+8000000
    ELSE FLOOR(RANDOM()*8000000)+3000000
END;

UPDATE projects p
SET actual_cost_to_date =
(
    p.planned_budget
    *
    p.complexity_factor
    *
    (0.6 + RANDOM()*0.8)
);

UPDATE projects
SET cost_variance = planned_budget - actual_cost_to_date;

UPDATE projects p
SET actual_cost_to_date =
    actual_cost_to_date +
    (
        SELECT COALESCE(SUM(delay_days),0)*200000
        FROM allocations a
        WHERE a.project_id = p.project_id
    );

SELECT project_id, planned_budget, actual_cost_to_date, cost_variance
FROM projects;

UPDATE projects
SET actual_cost_to_date = 
ROUND((planned_budget * (0.65 + RANDOM()*0.9))::numeric, 2);

UPDATE projects
SET cost_variance = planned_budget - actual_cost_to_date;

SELECT project_id, planned_budget, actual_cost_to_date, cost_variance
FROM projects
ORDER BY planned_budget DESC;

ALTER TABLE projects ADD COLUMN IF NOT EXISTS performance_category text;

UPDATE projects
SET performance_category =
CASE
WHEN RANDOM() < 0.2 THEN 'Critical Overrun'
WHEN RANDOM() < 0.5 THEN 'Slight Overrun'
WHEN RANDOM() < 0.8 THEN 'On Track'
ELSE 'High Efficiency'
END;

UPDATE projects
SET actual_cost_to_date =
CASE
WHEN performance_category = 'Critical Overrun'
    THEN planned_budget * (1.4 + RANDOM()*0.4)
WHEN performance_category = 'Slight Overrun'
    THEN planned_budget * (1.05 + RANDOM()*0.2)
WHEN performance_category = 'On Track'
    THEN planned_budget * (0.9 + RANDOM()*0.1)
WHEN performance_category = 'High Efficiency'
    THEN planned_budget * (0.6 + RANDOM()*0.2)
END;

UPDATE projects
SET cost_variance = planned_budget - actual_cost_to_date;

UPDATE allocations
SET delay_days = FLOOR(RANDOM()*5);

UPDATE projects
SET planned_budget =
CASE
WHEN project_name LIKE '%AI Customer Support Chatbot%' THEN FLOOR(RANDOM()*25000000)+20000000
WHEN project_name LIKE '%Business Intelligence Revamp%' THEN FLOOR(RANDOM()*20000000)+15000000
WHEN project_name LIKE '%CRM System Migration%' THEN FLOOR(RANDOM()*15000000)+8000000
ELSE FLOOR(RANDOM()*10000000)+3000000
END;

UPDATE projects
SET actual_cost_to_date =
CASE
WHEN performance_category = 'Critical Overrun'
    THEN planned_budget * (1.5 + RANDOM()*0.3)
WHEN performance_category = 'Slight Overrun'
    THEN planned_budget * (1.1 + RANDOM()*0.2)
WHEN performance_category = 'On Track'
    THEN planned_budget * (0.9 + RANDOM()*0.1)
WHEN performance_category = 'High Efficiency'
    THEN planned_budget * (0.6 + RANDOM()*0.2)
END;

UPDATE projects
SET cost_variance = planned_budget - actual_cost_to_date;

SELECT 
project_id,
project_name,
planned_budget,
actual_cost_to_date,
cost_variance,
performance_category
FROM projects
ORDER BY planned_budget DESC;

SELECT 
p.project_id,
p.project_name,
SUM(a.delay_days) AS total_delay_days,
AVG(a.delay_days) AS avg_delay_days,
COUNT(*) AS allocation_count
FROM projects p
JOIN allocations a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
ORDER BY total_delay_days DESC;

SELECT 
p.project_id,
p.project_name,
p.planned_budget,
p.actual_cost_to_date,
p.cost_variance,
a.employee_id,
a.allocated_hours,
a.delay_days,
e.department,
e.level
FROM public.projects p
LEFT JOIN public.allocations a 
    ON p.project_id = a.project_id
LEFT JOIN public.employees e 
    ON a.employee_id = e.employee_id
ORDER BY p.project_id
LIMIT 10;

SELECT *
FROM public.projects
ORDER BY project_id
LIMIT 10;

SELECT *
FROM public.allocations
ORDER BY employee_id, project_id
LIMIT 10;

SELECT *
FROM public.employees
ORDER BY employee_id
LIMIT 10;

UPDATE allocations
SET allocated_hours =
CASE
WHEN RANDOM() < 0.2 THEN FLOOR(RANDOM()*8 + 6)   -- heavy workload 6-14
WHEN RANDOM() < 0.6 THEN FLOOR(RANDOM()*4 + 4)   -- medium 4-8
ELSE FLOOR(RANDOM()*3 + 1)                       -- light 1-3
END;

UPDATE allocations
SET allocation_ratio = ROUND(allocated_hours / 10.0, 2);

UPDATE allocations
SET overtime_hours = GREATEST(allocated_hours - 10, 0),
    idle_hours = GREATEST(10 - allocated_hours, 0);

UPDATE allocations a
SET delay_days = FLOOR(
    RANDOM()*30 +
    (allocated_hours * 2)
);

UPDATE projects
SET complexity_factor =
CASE
    WHEN planned_budget > 20000000 THEN 1.5   -- Large complex programs
    WHEN planned_budget BETWEEN 10000000 AND 20000000 THEN 1.2
    WHEN planned_budget BETWEEN 5000000 AND 10000000 THEN 1.0
    ELSE 0.8
END;

UPDATE allocations
SET allocated_hours = 0,
    allocation_status = 'Bench'
WHERE RANDOM() < 0.1;

UPDATE allocations
SET idle_hours = GREATEST(10 - allocated_hours, 0);

UPDATE allocations
SET allocated_hours = FLOOR(RANDOM()*3 + 11)   -- 11-13 hours
WHERE project_id IN (
    SELECT project_id
    FROM projects
    ORDER BY planned_budget DESC
    LIMIT 3
);

UPDATE allocations
SET burnout_risk_level =
CASE
    WHEN allocated_hours >= 12 THEN 'High'
    WHEN allocated_hours BETWEEN 9 AND 11 THEN 'Medium'
    ELSE 'Low'
END;

UPDATE allocations
SET delay_days =
CASE
    WHEN burnout_risk_level = 'High' THEN FLOOR(RANDOM()*20 + 15)
    WHEN burnout_risk_level = 'Medium' THEN FLOOR(RANDOM()*10 + 5)
    ELSE FLOOR(RANDOM()*5)
END;

DELETE FROM allocations
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    WHERE department = 'Delivery'
);

DELETE FROM employees
WHERE department = 'Delivery';

UPDATE projects
SET delay_days = 
CASE
WHEN actual_end_date IS NOT NULL 
THEN GREATEST((actual_end_date - planned_end_date), 0)
ELSE 0
END;

UPDATE allocations a
SET burnout_score =
(
    (allocated_hours / 10.0) * 40 +
    (COALESCE(delay_days,0) / 30.0) * 30 +
    (COALESCE(consecutive_working_days,0) / 20.0) * 30
);


UPDATE kpi_metrics k
SET
planned_duration_days = (p.planned_end_date - p.planned_start_date),
actual_duration_days = 
CASE 
WHEN p.actual_end_date IS NOT NULL AND p.actual_start_date IS NOT NULL
THEN (p.actual_end_date - p.actual_start_date)
ELSE NULL
END,
critical_path_delay_days = 
CASE 
WHEN p.actual_end_date IS NOT NULL 
THEN GREATEST(p.actual_end_date - p.planned_end_date, 0)
ELSE 0
END,
cpi = 
CASE 
WHEN p.actual_cost_to_date = 0 THEN 0
ELSE ROUND(p.planned_budget / p.actual_cost_to_date,2)
END,
spi = 
CASE 
WHEN p.planned_budget = 0 THEN 0
ELSE ROUND(p.actual_cost_to_date / p.planned_budget,2)
END,
budget_utilization_pct =
ROUND((p.actual_cost_to_date / NULLIF(p.planned_budget,0))*100,2),
cost_overrun_pct =
ROUND((ABS(p.cost_variance)/NULLIF(p.planned_budget,0))*100,2),
utilization_pct =
(
SELECT ROUND(AVG(a.allocated_hours)/10.0*100,2)
FROM allocations a
WHERE a.project_id = p.project_id
),
overallocated_pct =
(
SELECT ROUND(
SUM(CASE WHEN a.allocated_hours > 10 THEN 1 ELSE 0 END)::numeric
/ NULLIF(COUNT(*),0) * 100
,2)
FROM allocations a
WHERE a.project_id = p.project_id
),
underutilized_pct =
(
SELECT ROUND(
SUM(CASE WHEN a.allocated_hours < 5 THEN 1 ELSE 0 END)::numeric
/ NULLIF(COUNT(*),0) * 100
,2)
FROM allocations a
WHERE a.project_id = p.project_id
),
total_idle_hours =
(
SELECT SUM(a.idle_hours)
FROM allocations a
WHERE a.project_id = p.project_id
),
avg_overtime_hours =
(
SELECT ROUND(AVG(a.overtime_hours),2)
FROM allocations a
WHERE a.project_id = p.project_id
),
burnout_high_pct =
(
SELECT ROUND(
SUM(CASE WHEN a.burnout_risk_level='High' THEN 1 ELSE 0 END)::numeric
/ NULLIF(COUNT(*),0) * 100
,2)
FROM allocations a
WHERE a.project_id = p.project_id
),
avg_delay_days =
(
SELECT ROUND(AVG(a.delay_days),2)
FROM allocations a
WHERE a.project_id = p.project_id
),
last_updated = CURRENT_DATE
FROM projects p
WHERE k.project_id = p.project_id;


INSERT INTO project_phases (
project_id,
phase_name,
planned_start_date,
planned_end_date,
actual_start_date,
actual_end_date
)
SELECT
p.project_id,
phase.phase_name,
p.planned_start_date + (phase.offset_start),
p.planned_start_date + (phase.offset_end),
p.planned_start_date + (phase.offset_start) + (RANDOM()*5)::int,
p.planned_start_date + (phase.offset_end) + (RANDOM()*10 - 3)::int
FROM projects p
CROSS JOIN (
VALUES
('Initiation', 0, 15),
('Design', 16, 45),
('Development', 46, 120),
('Testing', 121, 150)
) AS phase(phase_name, offset_start, offset_end);

UPDATE project_phases
SET phase_delay_days =
CASE
WHEN actual_end_date IS NOT NULL
THEN GREATEST(actual_end_date - planned_end_date, 0)
ELSE 0
END;

UPDATE projects p
SET actual_end_date =
(
SELECT MAX(actual_end_date)
FROM project_phases ph
WHERE ph.project_id = p.project_id
);

UPDATE kpi_metrics k
SET critical_path_delay_days =
(
SELECT SUM(phase_delay_days)
FROM project_phases ph
WHERE ph.project_id = k.project_id
);

SELECT employee_id, project_id, allocated_hours, is_active_employee, offboarded_date
FROM allocations
WHERE employee_id = 'E02626';

UPDATE projects
SET planned_budget = ROUND((3000000 + RANDOM()*12000000)::numeric,2);

UPDATE projects
SET actual_cost_to_date = ROUND((planned_budget * (0.7 + RANDOM()*0.6))::numeric,2);

UPDATE projects
SET cost_variance = planned_budget - actual_cost_to_date;

UPDATE allocations
SET burnout_risk_level =
CASE
WHEN allocated_hours >= 12 THEN 'High'
WHEN allocated_hours BETWEEN 9 AND 11 THEN 'Medium'
ELSE 'Low'
END;

UPDATE allocations
SET burnout_risk_level =
CASE
WHEN resource_utilization_efficiency::numeric >= 1.2
     OR overtime_hours >= 3
     OR consecutive_working_days >= 20
THEN 'High'
WHEN resource_utilization_efficiency::numeric BETWEEN 0.9 AND 1.19
     OR consecutive_working_days BETWEEN 10 AND 19
THEN 'Medium'
ELSE 'Low'
END;

UPDATE allocations
SET allocated_hours = FLOOR(6 + RANDOM()*6);

UPDATE allocations
SET resource_utilization_efficiency =
ROUND((allocated_hours / 10.0)::numeric,2);

UPDATE allocations
SET overtime_hours =
CASE
WHEN allocated_hours > 10 THEN allocated_hours - 10
ELSE 0
END;

UPDATE allocations
SET burnout_risk_level =
CASE
WHEN allocated_hours >= 11 THEN 'High'
WHEN allocated_hours BETWEEN 8 AND 10 THEN 'Medium'
ELSE 'Low'
END;

UPDATE kpi_metrics k
SET burnout_high_pct =
(
SELECT ROUND(
100.0 * COUNT(*) FILTER (WHERE burnout_risk_level='High') / COUNT(*),
2
)
FROM allocations a
WHERE a.project_id = k.project_id
);

SELECT project_id, burnout_high_pct
FROM kpi_metrics;

UPDATE kpi_metrics k
SET burnout_high_pct =
(
    SELECT ROUND(
        100.0 * COUNT(*) FILTER (WHERE a.allocated_hours >= 11) 
        / NULLIF(COUNT(*),0),
        2
    )
    FROM allocations a
    WHERE a.project_id = k.project_id
);

SELECT project_id, burnout_high_pct
FROM kpi_metrics
ORDER BY burnout_high_pct DESC;

UPDATE projects
SET budget_allocated = FLOOR(2000000 + RANDOM()*8000000);

SELECT 
    e.department,
    SUM(DISTINCT p.budget_allocated) AS total_budget,
    SUM(DISTINCT p.actual_cost_to_date) AS total_actual_cost,
    SUM(DISTINCT p.cost_variance) AS total_variance
FROM allocations a
JOIN employees e 
    ON a.employee_id = e.employee_id
JOIN projects p 
    ON a.project_id = p.project_id
GROUP BY e.department
ORDER BY total_budget DESC;

SELECT 
    department,
    COUNT(employee_id) AS employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC;

SELECT 
a.employee_id,
e.department
FROM allocations a
LEFT JOIN employees e
ON a.employee_id = e.employee_id
LIMIT 20;

SELECT 
e.department,
COUNT(DISTINCT a.employee_id) AS employees,
COUNT(DISTINCT a.project_id) AS projects
FROM allocations a
JOIN employees e
ON a.employee_id = e.employee_id
GROUP BY e.department
ORDER BY employees DESC;

SELECT 
    e.department,
    COUNT(DISTINCT e.employee_id) AS employees,
    COUNT(DISTINCT a.project_id) AS projects
FROM employees e
LEFT JOIN allocations a 
    ON e.employee_id = a.employee_id
GROUP BY e.department
ORDER BY employees DESC;

SELECT 
    e.department,
    COUNT(DISTINCT e.employee_id) AS employees,
    COUNT(DISTINCT a.project_id) AS projects,
    ROUND(AVG(a.allocated_hours),2) AS avg_allocated_hours
FROM employees e
LEFT JOIN allocations a 
    ON e.employee_id = a.employee_id
GROUP BY e.department
ORDER BY employees DESC;

SELECT
e.department,
SUM(DISTINCT p.budget_allocated) AS total_budget
FROM employees e
JOIN allocations a
ON e.employee_id = a.employee_id
JOIN projects p
ON a.project_id = p.project_id
GROUP BY e.department;

SELECT
e.department,
COUNT(DISTINCT p.project_id) AS projects
FROM employees e
JOIN allocations a
ON e.employee_id = a.employee_id
JOIN projects p
ON a.project_id = p.project_id
GROUP BY e.department;

UPDATE allocations
SET allocated_hours = 0
WHERE RANDOM() < 0.15;


UPDATE allocations
SET allocated_hours = FLOOR(11 + RANDOM()*3)
WHERE RANDOM() < 0.2;

UPDATE allocations
SET overtime_hours =
CASE
WHEN allocated_hours > 10 THEN allocated_hours - 10
ELSE 0
END;

UPDATE allocations
SET consecutive_working_days = FLOOR(15 + RANDOM()*10)
WHERE allocated_hours > 10;

UPDATE allocations
SET burnout_risk_level =
CASE
WHEN allocated_hours >= 11 OR overtime_hours >= 2 OR consecutive_working_days >= 20
THEN 'High'
WHEN allocated_hours BETWEEN 9 AND 10 OR consecutive_working_days BETWEEN 12 AND 19
THEN 'Medium'
ELSE 'Low'
END;

UPDATE kpi_metrics k
SET burnout_high_pct =
(
SELECT ROUND(
100.0 * COUNT(*) FILTER (WHERE burnout_risk_level='High') / COUNT(*),
2
)
FROM allocations a
WHERE a.project_id = k.project_id
);

SELECT burnout_risk_level, COUNT(*)
FROM allocations
GROUP BY burnout_risk_level;

UPDATE allocations
SET allocated_hours =
CASE
WHEN RANDOM() < 0.15 THEN FLOOR(11 + RANDOM()*3)  -- high workload
WHEN RANDOM() < 0.45 THEN FLOOR(9 + RANDOM()*2)   -- medium workload
WHEN RANDOM() < 0.70 THEN FLOOR(6 + RANDOM()*3)   -- normal workload
ELSE 0                                            -- idle
END;

UPDATE allocations
SET overtime_hours =
case
	
SELECT MIN(allocated_hours), MAX(allocated_hours)
FROM allocations;


WHEN allocated_hours > 10 THEN allocated_hours - 10
ELSE 0
END;

UPDATE allocations
SET consecutive_working_days = FLOOR(5 + RANDOM()*25);

UPDATE allocations
SET burnout_risk_level =
CASE
WHEN allocated_hours >= 11 OR consecutive_working_days >= 22
THEN 'High'
WHEN allocated_hours BETWEEN 9 AND 10 OR consecutive_working_days BETWEEN 15 AND 21
THEN 'Medium'
ELSE 'Low'
END;

SELECT allocated_hours, burnout_risk_level
FROM allocations
ORDER BY allocated_hours DESC
LIMIT 20;

UPDATE allocations
SET burnout_risk_level = NULL;

UPDATE allocations
SET burnout_risk_level =
CASE
WHEN allocated_hours >= 11 THEN 'High'
WHEN allocated_hours >= 9 THEN 'Medium'
WHEN allocated_hours <=8 then 'Low'
END;

UPDATE kpi_metrics k
SET burnout_high_pct =
(
SELECT ROUND(
100.0 * COUNT(*) FILTER (WHERE allocated_hours >= 11) /
NULLIF(COUNT(*),0),2
)
FROM allocations a
WHERE a.project_id = k.project_id
);

SELECT project_id, burnout_high_pct
FROM kpi_metrics
ORDER BY burnout_high_pct DESC;

SELECT project_id,
COUNT(*) FILTER (WHERE allocated_hours >= 11) AS high_hours,
COUNT(*) AS total_records
FROM allocations
GROUP BY project_id;

UPDATE kpi_metrics k
SET burnout_high_pct =
(
SELECT ROUND(
100.0 * COUNT(*) FILTER (WHERE allocated_hours >= 11) /
NULLIF(COUNT(*),0),2
)
FROM allocations a
WHERE a.project_id = k.project_id
);

SELECT * FROM kpi_metrics ORDER BY burnout_high_pct DESC;

UPDATE allocations
SET burnout_risk_level =
CASE
WHEN allocated_hours >= 10 THEN 'High'
WHEN allocated_hours >= 8 THEN 'Medium'
ELSE 'Low'
END;

UPDATE kpi_metrics k
SET burnout_high_pct =
(
SELECT ROUND(
100.0 * COUNT(*) FILTER (WHERE allocated_hours >= 10) /
NULLIF(COUNT(*),0),2
)
FROM allocations a
WHERE a.project_id = k.project_id
);

SELECT project_id, burnout_high_pct
FROM kpi_metrics
ORDER BY burnout_high_pct DESC;

UPDATE kpi_metrics
SET burnout_risk_level =
CASE
WHEN k.burnout_high_pct >= 40 THEN 'High'
WHEN k.burnout_high_pct >= 30 THEN 'Medium'
ELSE 'Low'
END
FROM kpi_metrics k
WHERE a.project_id = k.project_id;

SELECT burnout_risk_level, COUNT(*)
FROM allocations
GROUP BY burnout_risk_level;

UPDATE kpi_metrics
SET burnout_risk_level =
CASE
WHEN burnout_high_pct >= 40 THEN 'High'
WHEN burnout_high_pct >= 30 THEN 'Medium'
ELSE 'Low'
END;

ALTER TABLE kpi_metrics
ADD COLUMN burnout_risk_level VARCHAR(10);

SELECT project_id, burnout_high_pct, burnout_risk_level
FROM kpi_metrics
ORDER BY burnout_high_pct DESC;

select * from project_phases pp ;


UPDATE projects
SET performance_category =
CASE
    WHEN cost_variance > planned_budget * 0.15 THEN 'High Efficiency'
    WHEN cost_variance BETWEEN planned_budget * 0.05 AND planned_budget * 0.15 THEN 'Efficient'
    WHEN cost_variance BETWEEN -planned_budget * 0.05 AND planned_budget * 0.05 THEN 'On Track'
    WHEN cost_variance BETWEEN -planned_budget * 0.20 AND -planned_budget * 0.05 THEN 'Under Performance'
    ELSE 'Critical Overrun'
END;