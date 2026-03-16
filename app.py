import streamlit as st
import pandas as pd
from sqlalchemy import create_engine, text
from datetime import date

# ---------------- DB CONNECTION ----------------
engine = create_engine("postgresql+psycopg2://postgres:postgres@127.0.0.1:5432/project_bi")

# ---------------- SESSION ----------------
if "logged_in" not in st.session_state:
    st.session_state.logged_in = False
if "role" not in st.session_state:
    st.session_state.role = None
    
if "show_emp_master" not in st.session_state:
    st.session_state.show_emp_master = False

if "show_proj_master" not in st.session_state:
    st.session_state.show_proj_master = False


# ---------------- LOGIN ----------------
if not st.session_state.logged_in:
    st.set_page_config(layout="centered")
    st.title("🔐 Project BI Login")

    tab1, tab2 = st.tabs(["👤 Employee / Project Login", "👀 Viewer Login"])

    USER_PASSWORDS = {
        "user1": "1234",
        "user2": "1234",
        "user3": "1234"
    }

    PROJECT_ACCESS = {
        "user1": "P001",
        "user2": "P002",
        "user3": "P003"
    }

    # Project Head Login
    PROJECT_HEAD = {
        "phead": "1234"
    }

    VIEWER_USERS = {
    "user1": "user123",
    "user2": "user123",
    "user3": "user123"
}
    with tab1:
        st.subheader("Employee / Project Login")

        username = st.text_input("Username", key="emp_user")
        password = st.text_input("Password", type="password", key="emp_pass")

        login_btn = st.button("Login", key="emp_login")

        if login_btn:

            # Admin login
            if username == "admin" and password == "admin":
                st.session_state.logged_in = True
                st.session_state.role = "admin"
                st.rerun()

            # Project Head login
            elif username in PROJECT_HEAD and password == PROJECT_HEAD.get(username):
                st.session_state.logged_in = True
                st.session_state.role = "project_head"
                st.rerun()

            # Project User login
            elif username in PROJECT_ACCESS and password == USER_PASSWORDS.get(username):
                st.session_state.logged_in = True
                st.session_state.role = "project_user"
                st.session_state.project_id = PROJECT_ACCESS.get(username)
                st.rerun()

            else:
                st.error("❌ Invalid credentials")

    with tab2:
        st.subheader("Viewer Login")

        v_user = st.text_input("Viewer Username", key="v_user")
        v_pass = st.text_input("Viewer Password", type="password", key="v_pass")

        v_login_btn = st.button("Login as Viewer", key="v_login")

        if v_login_btn:
            if v_user in VIEWER_USERS and VIEWER_USERS[v_user] == v_pass:
                st.session_state.logged_in = True
                st.session_state.role = "viewer"
                st.session_state.viewer_id = v_user
                st.rerun()
            else:
                st.error("❌ Invalid viewer credentials")

    st.stop()
# ---------------- PAGE ----------------
st.set_page_config(layout="wide")
st.title("📊 Project BI – Resource Management Dashboard")

role = st.session_state.role

# NEW: Clean role names
role_names = {
    "admin": "Admin",
    "project_head": "Project Head",
    "project_user": "Project User",
    "viewer": "Viewer"
}

st.caption(f"Logged in as: **{role_names.get(st.session_state.role, st.session_state.role)}**")


# ---------------- LOGOUT ----------------
col1, col2 = st.columns([6, 1])
with col2:
    if st.button("🚪 Logout"):
        for k in list(st.session_state.keys()):
            del st.session_state[k]
        st.rerun()

# ---------------- LOAD MASTER DATA ----------------
@st.cache_data(ttl=30)
def load_table(q):
    return pd.read_sql(q, engine)

employees = load_table("SELECT * FROM employees")
projects = load_table("SELECT * FROM projects")
allocations = load_table("SELECT * FROM allocations")
departments = load_table("SELECT * FROM departments")   # ✅ ADD THIS

# 🔐 Restrict data for project users
if role == "project_user":
    allowed_project = st.session_state.project_id

    projects = projects[projects["project_id"].astype(str) == str(allowed_project)]
    allocations = allocations[allocations["project_id"].astype(str) == str(allowed_project)]

emp_ids = employees["employee_id"].astype(str).tolist()
proj_ids = projects["project_id"].astype(str).tolist()

# Department name → id mapping
dept_map = dict(zip(departments["department_name"], departments["department_id"]))  # ✅ ADD THIS

# ---------------- PROJECT USER OVERVIEW CARD ----------------
if role == "project_user":
    pid = st.session_state.project_id

    proj = projects[projects["project_id"].astype(str) == str(pid)].iloc[0]

    # 👥 Team size (active employees)
    team_size = allocations[
        (allocations["project_id"].astype(str) == str(pid)) &
        (allocations["is_active_employee"] == "Yes")
    ]["employee_id"].nunique()

    # 📌 Requirements needed = count of Yes in allocations
    req_needed_count = allocations[
        (allocations["project_id"].astype(str) == str(pid)) &
        (allocations["requirement_needed"] == "Yes")
    ].shape[0]

    st.subheader("📌 My Project Overview")

    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Project Name", proj.get("project_name", "-"))
    c2.metric("Status", proj.get("project_status", "-"))
    c3.metric("Client", proj.get("client_name", "-"))
    c4.metric("Team Size", team_size)

    def fmt_date(x):
        if pd.isna(x) or x is None:
            return "N/A"
        return pd.to_datetime(x).strftime("%d %b %Y")

    c5, c6, c7, c8 = st.columns(4)
    c5.metric("Start Date", fmt_date(proj.get("actual_start_date")))
    c6.metric("End Date", fmt_date(proj.get("actual_end_date")))
    c7.metric("Requirements Needed", req_needed_count)
    c8.metric("Project ID", pid)

    if req_needed_count > 0:
        st.warning(f"⚠️ {req_needed_count} open requirement(s) for this project.")

    st.divider()
# ---------------- ADMIN OVERVIEW DASHBOARD ----------------
if role in ["admin", "project_head"]:
    st.subheader("📊 Admin Overview")

    # 📁 Project KPIs
    total_projects = projects["project_id"].nunique()
    active_projects = projects[projects["project_status"] == "Active"]["project_id"].nunique()
    completed_projects = projects[projects["project_status"] == "Completed"]["project_id"].nunique()
    on_hold_projects = projects[projects["project_status"] == "On Hold"]["project_id"].nunique()

    # 👥 People KPIs
    active_employees = employees[employees["left_organization"] == "No"]["employee_id"].nunique()

    idle_people = allocations[
        allocations["allocation_status"].isin(["Bench", "Idle"])
    ]["employee_id"].nunique()

    # 📌 Requirements Needed (count of Yes in allocations)
    total_requirements = allocations[allocations["requirement_needed"] == "Yes"].shape[0]

    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Total Projects", total_projects)
    c2.metric("Active Projects", active_projects)
    c3.metric("Completed Projects", completed_projects)
    c4.metric("On Hold Projects", on_hold_projects)

    c5, c6, c7, c8 = st.columns(4)
    c5.metric("Active Employees", active_employees)
    c6.metric("Idle People", idle_people)
    c7.metric("Requirements Needed", total_requirements)
    c8.metric("Utilization Gap", max(total_requirements - idle_people, 0))  # optional insight


    # ---------------- ADMIN QUERY CONSOLE ----------------
if role == "admin":

    st.divider()
    st.subheader("🧠 Admin SQL Query Console")

    st.caption("Run SELECT queries to explore data or execute admin-level updates.")

    query = st.text_area("Enter SQL Query")

    if st.button("Run Query"):

        if query.strip().lower().startswith("select"):
            try:
                df_query = pd.read_sql(query, engine)
                st.dataframe(df_query, use_container_width=True)
            except Exception as e:
                st.error("❌ Query failed")
                st.exception(e)

        else:
            try:
                with engine.begin() as conn:
                    conn.execute(text(query))
                st.success("✅ Query executed successfully")
                st.cache_data.clear()
            except Exception as e:
                st.error("❌ Query execution failed")
                st.exception(e)


# ---------------- MASTER DATA QUICK EDIT ----------------
if role == "admin":
    st.divider()
    st.subheader("⚙️ Master Data (Employee & Project)")

    b1, b2 = st.columns(2)
    if b1.button("👤 View / Edit Employee Details", key="btn_emp_master"):
        st.session_state.show_emp_master = True
        st.session_state.show_proj_master = False

    if b2.button("📁 View / Edit Project Details", key="btn_proj_master"):
        st.session_state.show_proj_master = True
        st.session_state.show_emp_master = False


# ---------------- EMPLOYEE MASTER ----------------
if st.session_state.show_emp_master:
    st.markdown("### 👤 Employee Master Data")

    emp_id_master = st.selectbox("Select Employee ID", emp_ids, key="em_emp_master")
    emp_master = employees[employees["employee_id"].astype(str) == emp_id_master].iloc[0]

    c1, c2, c3 = st.columns(3)

    dept_names = departments["department_name"].dropna().unique().tolist()
    department = c1.selectbox(
        "Department",
        dept_names,
        index=dept_names.index(emp_master["department"]) if emp_master["department"] in dept_names else 0,
        key="dept_master"
    )

    department_id = dept_map[department]

    level = c3.text_input(
        "Level",
        value=str(emp_master["level"]),
        key="level_master"
    )

    c4, c5, c6 = st.columns(3)

    primary_skill = c4.text_input(
        "Primary Skill",
        value=str(emp_master["primary_skill"]),
        key="skill_master"
    )

    designation_list = employees["designation"].dropna().unique().tolist()

    designation = c5.selectbox(
        "Designation",
        designation_list,
        index=designation_list.index(emp_master["designation"]) if emp_master["designation"] in designation_list else 0,
        key="designation_master"
    )

    left_org_val = str(emp_master["left_organization"]).strip().title()

    left_organization = c6.selectbox(
        "Left Organization?",
        ["No", "Yes"],
        index=["No", "Yes"].index(left_org_val),
        key="left_org_master"
    )

    if left_organization == "Yes" and left_org_val != "Yes":
        st.info("ℹ️ Employee marked as left. All active allocations will be auto-offboarded today.")

    # Show fixed capacity instead of editable fields
    st.metric("Daily Capacity", "10 hrs")

    if st.button("💾 Update Employee", key="btn_update_employee"):

        with engine.begin() as conn:

            conn.execute(text("""
                UPDATE employees
                SET department=:d,
                    department_id=:did,
                    level=:l,
                    primary_skill=:s,
                    designation=:des,
                    left_organization=:lo
                WHERE employee_id=:eid;
            """), {
                "d": department,
                "did": department_id,
                "l": level,
                "s": primary_skill,
                "des": designation,
                "lo": left_organization,
                "eid": emp_id_master
            })

            if left_organization == "Yes":

                conn.execute(text("""
                    UPDATE allocations
                    SET offboarded_date = COALESCE(offboarded_date, CURRENT_DATE),
                        is_active_employee = 'No'
                    WHERE employee_id = :eid
                      AND (offboarded_date IS NULL OR offboarded_date >= CURRENT_DATE)
                      AND is_active_employee = 'Yes';
                """), {"eid": emp_id_master})

        st.success("✅ Employee updated successfully. Active allocations auto-offboarded.")
        st.cache_data.clear()
        st.rerun()


# ---------------- PROJECT MASTER ----------------
if st.session_state.show_proj_master:
    st.markdown("### 📁 Project Master Data")
    proj_id_master = st.selectbox("Select Project ID", proj_ids, key="pm_proj_master")
    proj_master = projects[projects["project_id"].astype(str) == proj_id_master].iloc[0]

    c1, c2, c3 = st.columns(3)
    pname = c1.text_input("Project Name", value=str(proj_master["project_name"]), key="proj_name_master")
    client = c2.text_input("Client Name", value=str(proj_master["client_name"]), key="client_name_master")
    status = c3.selectbox(
        "Project Status",
        ["Active", "Completed", "On Hold"],
        index=["Active", "Completed", "On Hold"].index(proj_master["project_status"]),
        key="proj_status_master"
    )

import os

# ---------------- POWER BI DASHBOARD (Admin / Project Head only) ----------------
if role in ["admin", "project_head"]:
    st.divider()
    st.subheader("📊 Advanced Visualization")

    if st.button("Open Power BI Dashboard"):
        os.startfile(r"C:\Users\Sheetz\Documents\bi_app\project_bi.pbix")
# ---------------- ACTIONS ----------------
if role in ["admin", "project_head", "project_user"]:
    st.divider()
    st.subheader("🛠️ What do you want to do?")
    c1, c2, c3, c4 = st.columns(4)

    with c1:
        if st.button("➕ Create", use_container_width=True):
            st.session_state.action = "Create"
    with c2:
        if st.button("👀 Read", use_container_width=True):
            st.session_state.action = "Read"
    with c3:
        if st.button("✏️ Update", use_container_width=True):
            st.session_state.action = "Update"
    with c4:
        if st.button("🗑️ Delete", use_container_width=True):
            st.session_state.action = "Delete"

    action = st.session_state.get("action", "Read")  # default view
else:
    # 👀 Viewer: no action buttons
    action = "Read"
    st.subheader("View Only Access")
    
# ---------------- CREATE (Employee -> Project -> Allocation) ----------------
if action == "Create" and role in ["admin", "project_head", "project_user"]:
    st.subheader("➕ Create Entry")

    DAILY_CAPACITY = 10  # 🔥 fixed daily capacity for everyone
    MAX_DAILY_LIMIT = 14  # 🔥 hard DB limit

    if role == "admin":
        entry_type = st.radio(
            "Entry Type",
            ["New Employee Entry", "Existing Employee Entry"],
            horizontal=True,
            key="entry_type_create"
        )
    else:
        entry_type = "Existing Employee Entry"
        st.info("Project users can allocate only existing employees. New employees can be added by Admin.")
    
    # ---------------- EMPLOYEE ----------------
    st.markdown("### 👤 Employee Details")

    active_allocs = pd.DataFrame()  # ✅ prevent NameError

    if entry_type == "Existing Employee Entry":
        employee_id = st.selectbox("Employee ID *", emp_ids, key="emp_id_create_existing")
        emp = employees[employees["employee_id"].astype(str) == employee_id].iloc[0]

        st.info(
            f"Dept: {emp['department']} | Designation: {emp['designation']} | "
            f"Level: {emp['level']} | Skill: {emp['primary_skill']}"
        )

        if str(emp["left_organization"]).strip().title() == "Yes":
            st.error("❌ This employee has left the organization.")
            st.stop()

    else:
        employee_id = st.text_input("New Employee ID *", key="new_emp_id_create")

        if employee_id in emp_ids:
            st.error("❌ This employee already exists. Use 'Existing Employee Entry' instead.")
            st.stop()

        department = st.selectbox(
            "Department",
            departments["department_name"].dropna().unique().tolist(),
            key="dept_create"
        )

        department_id = dept_map[department]

        level = st.selectbox(
            "Level",
            employees["level"].dropna().unique().tolist(),
            key="level_create"
        )

        primary_skill = st.selectbox(
            "Primary Skill",
            employees["primary_skill"].dropna().unique().tolist(),
            key="skill_create"
        )

        designation = st.selectbox(
            "Designation",
            sorted(employees["designation"].dropna().unique().tolist()),
            key="designation_create"
        )

        st.info("🕒 Daily Available Hours is fixed at **10 hours** for all employees.")

    st.metric("Employee Daily Capacity", f"{DAILY_CAPACITY} hrs")

    # ---------------- PROJECT ----------------
    st.markdown("### 📁 Project Details (Read-only)")
    if role == "project_user":
        project_id = st.session_state.get("project_id")
        st.text_input("Project ID *", value=str(project_id), disabled=True, key="proj_id_create_ro")
    elif role == "project_head":
        project_id = st.selectbox("Project ID *", proj_ids, key="proj_id_create_head")
    else:
        project_id = st.selectbox("Project ID *", proj_ids, key="proj_id_create")
    proj = projects[projects["project_id"].astype(str) == str(project_id)].iloc[0]
    # 🚫 Block allocation if project not Active
    if proj["project_status"] in ["Completed", "On Hold"]:
        st.error("🚫 Cannot create allocation. Project is not Active.")
        st.stop()
    p1, p2, p3 = st.columns(3)
    p1.text_input(
    "Project Name",
    value=str(proj.get("project_name", "")),
    disabled=True,
    key="proj_name_create_ro"
)
    p2.text_input(
    "Client Name",
    value=str(proj.get("client_name", "")),
    disabled=True,
    key="client_name_create_ro"
)
    p3.text_input(
    "Project Status",
    value=str(proj.get("project_status", "")),
    disabled=True,
    key="proj_status_create_ro"
)
    # ---------------- ALLOCATION ----------------
    st.markdown("### 🧮 Allocation Details")

    onboarded_date = st.date_input(
        "Onboarded Date *",
        value=date.today(),
        key="onboarded_create"
    )

    offboarded_date = st.date_input(
        "Offboarded Date",
        value=None,
        key="offboarded_create"
    )

    allocated_hours = st.number_input(
    "Allocated Hours (Daily)",
    min_value=0,
    max_value=MAX_DAILY_LIMIT,
    value=1,
    key="alloc_hours_create"
)

    st.caption("ℹ️ Normal capacity is 10 hrs/day. Up to 14 hrs/day allowed with override.")

    # Auto delay calculation from project
    if proj["actual_end_date"] and proj["planned_end_date"]:
        auto_delay = max((proj["actual_end_date"] - proj["planned_end_date"]).days, 0)
    else:
        auto_delay = 0

    delay_days = st.number_input(
        "Delay Days",
        min_value=0,
        value=int(auto_delay),
        key="delay_days_create"
    )

    if offboarded_date:
        is_active_employee = "No"
        st.selectbox("Is Active Employee?", ["No"], index=0, disabled=True, key="is_active_create_ro")
        st.info("ℹ️ Employee is marked inactive because Offboarded Date is set.")
    else:
        is_active_employee = st.selectbox("Is Active Employee?", ["Yes", "No"], key="is_active_create")

    if offboarded_date and offboarded_date < onboarded_date:
        st.error("❌ Offboarded Date cannot be before Onboarded Date.")
        st.stop()

    # ---------------- MULTIPLE PROJECT CHECK ----------------
    multi_proj_query = f"""
SELECT COUNT(DISTINCT project_id)
FROM allocations
WHERE employee_id = '{employee_id}'
AND is_active_employee = 'Yes'
AND (offboarded_date IS NULL OR offboarded_date >= CURRENT_DATE)
"""
    active_projects = pd.read_sql(multi_proj_query, engine).iloc[0, 0]
    # default = not allowed
    multi_project_override = False
    if active_projects > 0:
        st.warning("⚠️ Employee is already working on another active project.")
        multi_project_override = st.checkbox(
        "Allow employee to work on multiple projects",
        key="multi_project_override_create"
    )
    else:
        multi_project_override = True

if action == "Create" and role in ["admin", "project_head", "project_user"]:

    # ---------------- ACTIVE PROJECT CAPACITY VALIDATION ----------------
    DAILY_CAPACITY = 10
    MAX_DAILY_LIMIT = 14

    allow_override = True
    remaining_hours = DAILY_CAPACITY

    if entry_type == "Existing Employee Entry":

        live_query = f"""
        SELECT COALESCE(SUM(allocated_hours),0)
        FROM allocations
        WHERE employee_id = '{employee_id}'
        AND is_active_employee = 'Yes'
        AND (offboarded_date IS NULL OR offboarded_date >= CURRENT_DATE)
        """

        current_total = pd.read_sql(live_query, engine).iloc[0, 0]

    else:
        current_total = 0


    new_total = current_total + allocated_hours
    remaining_hours = max(DAILY_CAPACITY - new_total, 0)

    st.info(f"📊 Current active daily allocation: {current_total} hrs")
    st.info(f"🧮 After this allocation: {new_total} hrs")
    st.info(f"💤 Idle hours after allocation: {remaining_hours} hrs")


    if new_total > DAILY_CAPACITY:
        st.warning("⚠️ Over-allocation detected!")

        allow_override = st.checkbox(
            "I understand and want to over-allocate",
            key="override_overalloc_create"
        )


    if new_total > MAX_DAILY_LIMIT:
        st.error("❌ Cannot exceed 14 hrs/day (DB constraint).")
        st.stop()


    # ---------------- SAME PROJECT CHECK ----------------
    same_proj_query = f"""
    SELECT COUNT(*)
    FROM allocations
    WHERE employee_id = '{employee_id}'
    AND project_id = '{project_id}'
    AND is_active_employee = 'Yes'
    AND (offboarded_date IS NULL OR offboarded_date >= CURRENT_DATE)
    """

    same_project_active = pd.read_sql(same_proj_query, engine).iloc[0, 0]

    if same_project_active > 0:
        st.error("❌ Employee is already actively allocated to this project.")
        st.stop()


    # ---------------- CREATE ----------------
    if st.button("Create Entry", key="btn_create_entry") and (
        entry_type == "New Employee Entry" or (allow_override and multi_project_override)
    ):

        if not multi_project_override:
            st.error("❌ Employee is already working on another project. Tick the checkbox to allow multiple projects.")
            st.stop()

        if not allow_override:
            st.error("❌ Over-allocation detected. Tick the override checkbox to continue.")
            st.stop()

        try:
            with engine.begin() as conn:

                if entry_type == "New Employee Entry":

                    conn.execute(text("""
                        INSERT INTO employees (
                            employee_id, department, department_id, level,
                            primary_skill, designation, available_hours,
                            daily_hours_spent, left_organization
                        )
                        VALUES (:eid, :dept, :dept_id, :lvl, :skill, :desig, 10, 0, 'No')
                        ON CONFLICT (employee_id) DO NOTHING;
                    """), {
                        "eid": employee_id,
                        "dept": department,
                        "dept_id": department_id,
                        "lvl": level,
                        "skill": primary_skill,
                        "desig": designation
                    })


                conn.execute(text("""
                    INSERT INTO allocations (
                        employee_id, project_id, onboarded_date, offboarded_date,
                        allocated_hours, delay_days, is_active_employee
                    )
                    VALUES (
                        :eid, :pid, :onb, :offb, :alloc, :delay, :active
                    )
                    ON CONFLICT (employee_id, project_id, onboarded_date)
                    DO UPDATE SET
                        allocated_hours = EXCLUDED.allocated_hours,
                        delay_days = EXCLUDED.delay_days,
                        offboarded_date = EXCLUDED.offboarded_date,
                        is_active_employee = EXCLUDED.is_active_employee;
                """), {
                    "eid": employee_id,
                    "pid": project_id,
                    "onb": onboarded_date,
                    "offb": offboarded_date,
                    "alloc": allocated_hours,
                    "delay": delay_days,
                    "active": is_active_employee.strip().title()
                })


            st.success(f"✅ Allocation saved. Remaining daily capacity: {remaining_hours} hrs")

            st.cache_data.clear()
            st.rerun()


        except Exception as e:

            if "chk_alloc_reasonable" in str(e):
                st.error("❌ Max allowed hours is 14/day (DB constraint).")

            elif "duplicate key value" in str(e):
                st.error("❌ Allocation already exists for this employee, project & date.")

            else:
                st.error("❌ Database validation failed.")

            st.exception(e)
# ---------------- READ ---------------- 
elif action == "Read":

    df = pd.read_sql("""
    SELECT 
        a.employee_id,
        a.project_id,
        a.onboarded_date,
        a.offboarded_date,
        a.allocated_hours,
        a.delay_days,
        a.is_active_employee,

        e.level,
        e.primary_skill,
        e.department,
        e.designation,

        p.project_name,
        p.project_status,

        SUM(CASE 
                WHEN a.is_active_employee='Yes' 
                     AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE) 
                THEN a.allocated_hours 
                ELSE 0 
            END)
        OVER (PARTITION BY a.employee_id, a.onboarded_date) 
        AS total_daily_hours,

        CASE 
            WHEN SUM(CASE 
                        WHEN a.is_active_employee='Yes' 
                             AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE) 
                        THEN a.allocated_hours 
                        ELSE 0 
                     END)
                 OVER (PARTITION BY a.employee_id, a.onboarded_date) > 10 
            THEN 'Overallocated'
            WHEN SUM(CASE 
                        WHEN a.is_active_employee='Yes' 
                             AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE) 
                        THEN a.allocated_hours 
                        ELSE 0 
                     END)
                 OVER (PARTITION BY a.employee_id, a.onboarded_date) = 0 
            THEN 'Bench'
            ELSE 'Allocated'
        END AS allocation_status,

        GREATEST(
            SUM(CASE 
                    WHEN a.is_active_employee='Yes' 
                         AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE) 
                    THEN a.allocated_hours 
                    ELSE 0 
                END)
            OVER (PARTITION BY a.employee_id, a.onboarded_date) - 10,
            0
        ) AS overtime_hours,

        GREATEST(
            10 - SUM(CASE 
                        WHEN a.is_active_employee='Yes' 
                             AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE)
                        THEN a.allocated_hours 
                        ELSE 0 
                     END)
            OVER (PARTITION BY a.employee_id, a.onboarded_date),
            0
        ) AS idle_hours,

        ROUND(
            LEAST(
                SUM(CASE 
                        WHEN a.is_active_employee='Yes' 
                             AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE) 
                        THEN a.allocated_hours 
                        ELSE 0 
                     END)
                OVER (PARTITION BY a.employee_id, a.onboarded_date) / 10.0,
                1
            ),
            2
        ) AS resource_utilization_efficiency,

        CASE 
            WHEN SUM(CASE 
                        WHEN a.is_active_employee='Yes' 
                             AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE)
                        THEN a.allocated_hours 
                        ELSE 0 
                     END)
                 OVER (PARTITION BY a.employee_id, a.onboarded_date) > 12 THEN 'High'
            WHEN SUM(CASE 
                        WHEN a.is_active_employee='Yes' 
                             AND (a.offboarded_date IS NULL OR a.offboarded_date >= CURRENT_DATE) 
                        THEN a.allocated_hours 
                        ELSE 0 
                     END)
                 OVER (PARTITION BY a.employee_id, a.onboarded_date) BETWEEN 9 AND 12 THEN 'Medium'
            ELSE 'Low'
        END AS burnout_risk_level,

        COUNT(*) FILTER (
    WHERE a.is_active_employee = 'Yes'
) OVER (
    PARTITION BY a.employee_id
) AS consecutive_working_days,

        ROUND(
            CASE 
                WHEN p.actual_start_date IS NOT NULL 
                     AND p.actual_end_date IS NOT NULL 
                THEN LEAST(
                    (CURRENT_DATE - p.actual_start_date)::numeric /
                    NULLIF((p.actual_end_date - p.actual_start_date),0) * 100,
                    100
                )
                ELSE 0
            END, 
        2) AS progress_percentage

    FROM allocations a
    LEFT JOIN employees e ON a.employee_id = e.employee_id
    LEFT JOIN projects p ON a.project_id = p.project_id
    ORDER BY a.employee_id, a.onboarded_date, a.project_id
    """, engine)

    if role == "project_user":
        df = df[df["project_id"].astype(str) == str(st.session_state.project_id)]

    # ---------------- Filters ----------------
    st.subheader("🔎 Filters")

    filter_cols = ["All"] + df.columns.tolist()

    f1, f2, f3 = st.columns([2, 3, 1])
    with f1:
        field = st.selectbox("Choose field", filter_cols)
    with f2:
        value = st.text_input("Enter value (partial match)")
    with f3:
        st.markdown("<br>", unsafe_allow_html=True)
        apply_btn = st.button("Apply Filter")

    if apply_btn and value:
        if field == "All":
            mask = df.astype(str).apply(lambda x: x.str.contains(value, case=False)).any(axis=1)
            df = df[mask]
        else:
            df = df[df[field].astype(str).str.contains(value, case=False)]

    # ---------------- Date Filter ----------------
    st.subheader("📅 Date Filter")

    use_dates = st.selectbox("Filter type", ["None", "Custom Date Range"])

    if use_dates == "Custom Date Range":
        date_col = st.selectbox("Apply on", ["onboarded_date", "offboarded_date", "Both"])
        d1, d2 = st.columns(2)
        with d1:
            start = st.date_input("From")
        with d2:
            end = st.date_input("To")

        if date_col == "onboarded_date":
            df = df[(df["onboarded_date"] >= start) & (df["onboarded_date"] <= end)]
        elif date_col == "offboarded_date":
            df = df[(df["offboarded_date"] >= start) & (df["offboarded_date"] <= end)]
        else:
            df = df[
                ((df["onboarded_date"] >= start) & (df["onboarded_date"] <= end)) |
                ((df["offboarded_date"] >= start) & (df["offboarded_date"] <= end))
            ]

    # ---------------- Final Display ----------------
    st.dataframe(df, use_container_width=True)
    
# ---------------- UPDATE (DB-Validated Fields Locked) ----------------
elif action == "Update" and role in ["admin", "project_head", "project_user"]:
    st.subheader("✏️ Update Entry")

    # 🔄 Fresh read from DB to avoid cache issues
    fresh_allocations = pd.read_sql("SELECT * FROM allocations", engine)

    # 🔒 Restrict project users to their own project
    if role == "project_user":
        fresh_allocations = fresh_allocations[
            fresh_allocations["project_id"].astype(str) == str(st.session_state.project_id)
        ]

    emp_ids_update = fresh_allocations["employee_id"].astype(str).unique().tolist()
    employee_id = st.selectbox("Employee ID", emp_ids_update, key="upd_emp_id")

    emp_rows = fresh_allocations[fresh_allocations["employee_id"].astype(str) == employee_id]
    project_ids = emp_rows["project_id"].astype(str).unique().tolist()
    project_id = st.selectbox("Project ID", project_ids, key="upd_proj_id")

    proj_rows = emp_rows[emp_rows["project_id"].astype(str) == project_id].copy()
    proj_rows["onboarded_date"] = pd.to_datetime(proj_rows["onboarded_date"]).dt.date

    onboarded_date = st.selectbox("Onboarded Date", proj_rows["onboarded_date"].tolist(), key="upd_onboarded")
    rec = proj_rows[proj_rows["onboarded_date"] == onboarded_date].iloc[0]

    # 🔑 Force widget refresh per record
    widget_suffix = f"{employee_id}_{project_id}_{onboarded_date}"

    emp = employees[employees["employee_id"].astype(str) == employee_id].iloc[0]
    proj = projects[projects["project_id"].astype(str) == project_id].iloc[0]

    # 🚫 Block update if project not Active
    if proj["project_status"] in ["Completed", "On Hold"]:
        st.error("🚫 Cannot update allocation. Project is not Active.")
        st.stop()

    emp_left = str(emp["left_organization"]).strip().title() == "Yes"

    # 👤 Employee (READ-ONLY)
    st.markdown("### 👤 Employee (read-only)")
    c1, c2, c3, c4, c5 = st.columns(5)
    c1.text_input("Department", value=str(emp["department"]), disabled=True, key=f"upd_dept_ro_{widget_suffix}")
    c2.text_input("Level", value=str(emp["level"]), disabled=True, key=f"upd_level_ro_{widget_suffix}")
    c3.text_input("Primary Skill", value=str(emp["primary_skill"]), disabled=True, key=f"upd_skill_ro_{widget_suffix}")
    c4.text_input("Designation", value=str(emp["designation"]), disabled=True, key=f"upd_desig_ro_{widget_suffix}")
    c5.number_input("Daily Hours Spent", value=int(emp["daily_hours_spent"]), disabled=True, key=f"upd_daily_ro_{widget_suffix}")

    # 📁 Project (read-only)
    st.markdown("### 📁 Project (read-only)")
    st.text_input("Project Name", value=str(proj.get("project_name", "")), disabled=True, key=f"upd_proj_name_ro_{widget_suffix}")
    st.text_input("Client Name", value=str(proj.get("client_name", "")), disabled=True, key=f"upd_client_name_ro_{widget_suffix}")
    st.text_input("Project Status", value=str(proj.get("project_status", "")), disabled=True, key=f"upd_proj_status_ro_{widget_suffix}")

    # 🧮 Allocation
    st.markdown("### 🧮 Allocation")
    allocated_hours = st.number_input(
        "Allocated Hours",
        min_value=0,
        max_value=14,
        value=int(rec["allocated_hours"]),
        key=f"upd_alloc_hours_{widget_suffix}"
    )

    # Auto-calculate delay from project dates
    if proj.get("actual_end_date") and proj.get("planned_end_date"):
        auto_delay = max((proj["actual_end_date"] - proj["planned_end_date"]).days, 0)
    else:
        auto_delay = 0

    delay_days = st.number_input(
        "Delay Days",
        min_value=0,
        value=auto_delay,
        key=f"upd_delay_days_{widget_suffix}"
    )

    if emp_left:
        is_active_employee = "No"
        offboarded_date = date.today()
        st.selectbox("Is Active Employee?", ["No"], index=0, disabled=True, key=f"upd_is_active_ro_{widget_suffix}")
        st.date_input("Offboarded Date", value=offboarded_date, disabled=True, key=f"upd_offboarded_ro_{widget_suffix}")
        st.info("ℹ️ Employee has left the organization. Allocation forced inactive.")
    else:
        is_active_employee = st.selectbox(
            "Is Active Employee?",
            ["Yes", "No"],
            index=["Yes", "No"].index(str(rec["is_active_employee"]).strip().title()),
            key=f"upd_is_active_{widget_suffix}"
        )

        if is_active_employee == "No":
            offboarded_date = st.date_input(
                "Offboarded Date",
                value=rec["offboarded_date"] if pd.notna(rec["offboarded_date"]) else date.today(),
                key=f"upd_offboarded_{widget_suffix}"
            )
        else:
            offboarded_date = None
            st.info("ℹ️ Allocation marked active. Offboarded date will be cleared.")

    if offboarded_date and offboarded_date < onboarded_date:
        st.error("❌ Offboarded date cannot be before onboarded date.")
        st.stop()

    # 🔥 CAPACITY CHECK
    DAILY_CAPACITY = 10

    live_query = f"""
SELECT COALESCE(SUM(allocated_hours),0)
FROM allocations
WHERE employee_id = '{employee_id}'
AND is_active_employee = 'Yes'
AND (offboarded_date IS NULL OR offboarded_date >= CURRENT_DATE)
AND NOT (project_id = '{project_id}' AND onboarded_date = '{onboarded_date}')
"""

    current_total = pd.read_sql(live_query, engine).iloc[0, 0]
    new_total = current_total + allocated_hours
    remaining_hours = max(DAILY_CAPACITY - new_total, 0)

    MAX_DAILY_LIMIT = 14
    if new_total > MAX_DAILY_LIMIT:
        st.error("❌ Total daily allocation cannot exceed 14 hrs.")
        st.stop()

    st.info(f"📊 Current active daily allocation: {current_total} hrs")
    st.info(f"🧮 After this update: {new_total} hrs")
    st.info(f"💤 Idle hours after update: {remaining_hours} hrs")

    allow_override = True
    if new_total > DAILY_CAPACITY:
        st.warning("⚠️ Over-allocation detected!")
        allow_override = st.checkbox("I understand and want to over-allocate", key=f"override_overalloc_update_{widget_suffix}")

    # ---------------- UPDATE ----------------
    if st.button("Update Entry", key=f"btn_update_entry_{widget_suffix}") and allow_override:
        try:
            if emp_left:
                is_active_employee = "No"
                offboarded_date = date.today()
            elif is_active_employee == "Yes":
                offboarded_date = None
            else:
                is_active_employee = "No"

            with engine.begin() as conn:
                conn.execute(text("""
                    UPDATE allocations
                    SET allocated_hours=:alloc,
                        delay_days=:delay,
                        offboarded_date=:offb,
                        is_active_employee=:active
                    WHERE employee_id=:eid AND project_id=:pid AND onboarded_date=:onb;
                """), {
                    "alloc": allocated_hours,
                    "delay": delay_days,
                    "offb": offboarded_date,
                    "active": is_active_employee.strip().title(),
                    "eid": employee_id,
                    "pid": project_id,
                    "onb": onboarded_date
                })

            st.success("✅ Allocation updated successfully!")
            st.cache_data.clear()
            st.rerun()

        except Exception as e:
            msg = str(e)
            if "chk_alloc_reasonable" in msg:
                st.error("❌ Max allowed hours is 14/day.")
            else:
                st.error("❌ Database update failed.")
            st.exception(e)
# ---------------- DELETE ----------------
elif action == "Delete" and role in ["admin", "project_head", "project_user"]:
    st.subheader("🗑️ Delete Entry")

    # 🔒 Restrict project users to their own project
    if role == "project_user":
        emp_rows = allocations[allocations["project_id"].astype(str) == str(st.session_state.project_id)]
        employee_id = st.selectbox("Employee ID", emp_rows["employee_id"].astype(str).unique().tolist())
    else:
        employee_id = st.selectbox("Employee ID", emp_ids)
        emp_rows = allocations[allocations["employee_id"].astype(str) == employee_id]

    project_ids = emp_rows["project_id"].astype(str).unique().tolist()
    project_id = st.selectbox("Project ID", project_ids)

    proj_rows = emp_rows[emp_rows["project_id"].astype(str) == project_id]
    onboarded_date = st.selectbox("Onboarded Date", proj_rows["onboarded_date"].tolist())

    if st.button("Delete Entry"):
        with engine.begin() as conn:
            conn.execute(text("""
                DELETE FROM allocations
                WHERE employee_id=:eid AND project_id=:pid AND onboarded_date=:onb;
            """), {
                "eid": employee_id,
                "pid": project_id,
                "onb": onboarded_date
            })

        st.success("🗑️ Deleted successfully!")
        st.cache_data.clear()
        st.rerun()


