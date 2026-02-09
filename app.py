import streamlit as st
import pandas as pd
from sqlalchemy import text
from db import engine

st.set_page_config(page_title="Project BI – Smart Create", layout="wide")
st.title("📊 Resource Allocation – Smart Create Form")

# ---------- Helpers ----------
@st.cache_data(ttl=60)
def get_employees_master():
    return pd.read_sql("SELECT * FROM public.employees ORDER BY employee_id;", engine)

@st.cache_data(ttl=60)
def get_projects_master():
    return pd.read_sql("SELECT * FROM public.projects ORDER BY project_id;", engine)

def get_employee_history(emp_id):
    q = """
    SELECT project_id, onboarded_date, offboarded_date, allocation_status, allocated_hours
    FROM public.allocations
    WHERE employee_id = :eid
    ORDER BY onboarded_date DESC NULLS LAST;
    """
    return pd.read_sql(text(q), engine, params={"eid": emp_id})

# ---------- Load masters ----------
employees_df = get_employees_master()
projects_df = get_projects_master()

employee_ids = employees_df["employee_id"].tolist() if not employees_df.empty else []
project_ids = projects_df["project_id"].tolist() if not projects_df.empty else []

# ---------- Mode ----------
mode = st.radio("Mode", ["New Entry", "Existing Employee (Reference)"], horizontal=True)

selected_emp = None
if mode == "Existing Employee (Reference)" and employee_ids:
    selected_emp = st.selectbox("Employee ID", employee_ids)
    st.caption("Recent allocations (reference only):")
    st.write(get_employee_history(selected_emp))

st.divider()
st.subheader("Create New Allocation Entry")

# ---------- Project auto-fill ----------
selected_project = st.selectbox("Project ID *", project_ids)

project_row = {}
if selected_project and not projects_df.empty:
    row = projects_df[projects_df["project_id"] == selected_project]
    if not row.empty:
        project_row = row.iloc[0].to_dict()

# ---------- Employee auto-fill (if existing) ----------
employee_row = {}
if selected_emp and not employees_df.empty:
    erow = employees_df[employees_df["employee_id"] == selected_emp]
    if not erow.empty:
        employee_row = erow.iloc[0].to_dict()

with st.form("create_form", clear_on_submit=True):
    st.markdown("### 👤 Employee Details")
    c1, c2, c3 = st.columns(3)
    with c1:
        employee_id = st.text_input("Employee ID *", value=selected_emp or "")
        department = st.text_input("Department", value=employee_row.get("department", ""))
    with c2:
        level = st.text_input("Level", value=employee_row.get("level", ""))
        primary_skill = st.text_input("Primary Skill", value=employee_row.get("primary_skill", ""))
    with c3:
        notice_period = st.selectbox("Notice Period", ["Yes", "No"], index=0 if employee_row.get("notice_period", "No") == "Yes" else 1)

    st.markdown("### 📁 Project Details (auto-filled, read-only)")
    p1, p2, p3 = st.columns(3)
    with p1:
        project_name = st.text_input("Project Name", value=project_row.get("project_name", ""), disabled=True)
        client_name = st.text_input("Client Name", value=project_row.get("client_name", ""), disabled=True)
    with p2:
        project_manager = st.text_input("Project Manager", value=project_row.get("project_manager", ""), disabled=True)
        project_status = st.text_input("Project Status", value=project_row.get("project_status", ""), disabled=True)
    with p3:
        planned_start_date = st.date_input("Planned Start Date", value=project_row.get("planned_start_date"), disabled=True)
        planned_end_date = st.date_input("Planned End Date", value=project_row.get("planned_end_date"), disabled=True)

    st.markdown("### 📊 Allocation Details")
    a1, a2, a3 = st.columns(3)
    with a1:
        onboarded_date = st.date_input("Onboarded Date")
        offboarded_date = st.date_input("Offboarded Date")
    with a2:
        allocated_hours = st.number_input("Allocated Hours", min_value=0, step=1)
        allocation_ratio = st.number_input("Allocation Ratio", min_value=0.0, step=0.01)
        allocation_status = st.selectbox("Allocation Status", ["Allocated", "Bench", "Overloaded", "Overallocated"])
    with a3:
        overtime_hours = st.number_input("Overtime Hours", min_value=0, step=1)
        burnout_risk_level = st.selectbox("Burnout Risk Level", ["Low", "Medium", "High"])

    submitted = st.form_submit_button("Create Entry")

    if submitted:
        if not employee_id or not selected_project:
            st.error("❌ Employee ID and Project ID are mandatory.")
        else:
            with engine.begin() as conn:
                conn.execute(text("""
                    INSERT INTO public.allocations (
                        employee_id, project_id, onboarded_date, offboarded_date,
                        allocated_hours, allocation_ratio, allocation_status,
                        overtime_hours, burnout_risk_level
                    )
                    VALUES (
                        :employee_id, :project_id, :onboarded_date, :offboarded_date,
                        :allocated_hours, :allocation_ratio, :allocation_status,
                        :overtime_hours, :burnout_risk_level
                    )
                """), {
                    "employee_id": employee_id,
                    "project_id": selected_project,
                    "onboarded_date": onboarded_date,
                    "offboarded_date": offboarded_date,
                    "allocated_hours": allocated_hours,
                    "allocation_ratio": allocation_ratio,
                    "allocation_status": allocation_status,
                    "overtime_hours": overtime_hours,
                    "burnout_risk_level": burnout_risk_level
                })

            st.success("✅ New allocation entry created successfully!")
            st.cache_data.clear()
            st.rerun()

