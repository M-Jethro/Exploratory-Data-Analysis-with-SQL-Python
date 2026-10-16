"""Load the paintings CSV files into a MySQL database.

Configuration is supplied through environment variables:
    PAINTINGS_DB_USER       Required database username.
    PAINTINGS_DB_PASSWORD   Required database password.
    PAINTINGS_DB_HOST       Optional; defaults to localhost.
    PAINTINGS_DB_PORT       Optional; defaults to 3306.
    PAINTINGS_DB_NAME       Optional; defaults to paintings.
    PAINTINGS_DATA_DIR      Optional; defaults to ./archive next to this script.

Warning: tables are replaced when this script runs. Use a dedicated practice
database and back up any data you need to keep.
"""

import os
from pathlib import Path

import pandas as pd
from sqlalchemy import URL, create_engine


BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = Path(
    os.getenv("PAINTINGS_DATA_DIR", str(BASE_DIR / "archive"))
).expanduser()

DB_USER = os.getenv("PAINTINGS_DB_USER")
DB_PASSWORD = os.getenv("PAINTINGS_DB_PASSWORD")
DB_HOST = os.getenv("PAINTINGS_DB_HOST", "localhost")
DB_PORT = int(os.getenv("PAINTINGS_DB_PORT", "3306"))
DB_NAME = os.getenv("PAINTINGS_DB_NAME", "paintings")

CSV_TABLES = (
    "artist",
    "canvas_size",
    "image_link",
    "museum_hours",
    "museum",
    "product_size",
    "subject",
    "work",
)


def main() -> None:
    """Validate configuration and load the CSV files into MySQL."""
    if not DB_USER or not DB_PASSWORD:
        raise SystemExit(
            "Missing database credentials. Set PAINTINGS_DB_USER and "
            "PAINTINGS_DB_PASSWORD in your environment before running."
        )

    missing_files = [
        DATA_DIR / f"{table_name}.csv"
        for table_name in CSV_TABLES
        if not (DATA_DIR / f"{table_name}.csv").is_file()
    ]
    if missing_files:
        missing_list = "\n".join(f"  - {path}" for path in missing_files)
        raise SystemExit(
            f"Could not find these required CSV files in {DATA_DIR}:\n"
            f"{missing_list}\n"
            "Set PAINTINGS_DATA_DIR to the directory containing the files."
        )

    database_url = URL.create(
        "mysql+pymysql",
        username=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
    )

    engine = create_engine(database_url)
    try:
        with engine.begin() as connection:
            for table_name in CSV_TABLES:
                csv_path = DATA_DIR / f"{table_name}.csv"
                dataframe = pd.read_csv(csv_path)
                dataframe.to_sql(
                    table_name,
                    con=connection,
                    if_exists="replace",
                    index=False,
                )
                print(
                    f"Loaded {len(dataframe):,} rows into "
                    f"'{table_name}' from {csv_path.name}"
                )
    finally:
        engine.dispose()


if __name__ == "__main__":
    main()
