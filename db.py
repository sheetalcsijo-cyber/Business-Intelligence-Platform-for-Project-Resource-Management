from sqlalchemy import create_engine

DB_USER = "postgres"
DB_PASS = "postgres"   # <-- put your actual password here
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "project_bi"

engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}",
    pool_pre_ping=True
)
