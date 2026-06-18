import argparse
import json
import os
import sys
from pathlib import Path

import requests
import yaml

_REPO_ROOT = Path(__file__).resolve().parents[1]
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from scripts.lib.canvas_client import CanvasClient
from scripts.lib.passwords import (
    password_for_login,
    synthetic_student_login,
    synthetic_student_password,
)


def load_env_file(env_path: Path) -> None:
    if not env_path.exists():
        return
    for raw_line in env_path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def require_env(key: str) -> str:
    value = os.getenv(key, "").strip()
    if not value:
        raise SystemExit(f"Missing required environment variable: {key}")
    return value


def user_id_from_payload(payload: dict) -> int:
    if "id" in payload:
        return payload["id"]
    if "user" in payload and isinstance(payload["user"], dict) and "id" in payload["user"]:
        return payload["user"]["id"]
    raise ValueError(f"Cannot determine user id from payload keys: {list(payload.keys())}")


def token_from_payload(payload: dict) -> str:
    for key in ("visible_token", "token", "full_token"):
        token = payload.get(key)
        if token:
            return token
    return ""


class Seeder:
    def __init__(self, client: CanvasClient | None, config: dict, dry_run: bool, skip_students: bool):
        self.client = client
        self.config = config
        self.dry_run = dry_run
        self.skip_students = skip_students
        self._dry_run_user_id = 100000
        self._dry_run_course_id = 900000
        self.users_by_login: dict[str, dict] = {}
        self.courses_by_sis: dict[str, dict] = {}

    def log(self, message: str) -> None:
        print(message)

    def _next_dry_run_user(self, login: str, name: str) -> dict:
        self._dry_run_user_id += 1
        return {"id": self._dry_run_user_id, "login_id": login, "name": name}

    def _next_dry_run_course(self, sis_id: str, code: str, name: str) -> dict:
        self._dry_run_course_id += 1
        return {"id": self._dry_run_course_id, "sis_course_id": sis_id, "course_code": code, "name": name}

    def ensure_user(self, login: str, name: str, password: str) -> dict:
        if self.dry_run:
            self.log(f"[dry-run] ensure user {login}")
            if login not in self.users_by_login:
                self.users_by_login[login] = self._next_dry_run_user(login, name)
            return self.users_by_login[login]

        existing = self.client.find_user_by_login(login)
        if existing:
            self.log(f"found user {login}")
            self.users_by_login[login] = existing
            return existing

        self.log(f"creating user {login}")
        created = self.client.create_user(login=login, name=name, password=password)
        user = created if isinstance(created, dict) else {"id": created}
        if "login_id" not in user:
            user["login_id"] = login
        self.users_by_login[login] = user
        return user

    def ensure_course(self, sis_id: str, code: str, name: str) -> dict:
        if self.dry_run:
            self.log(f"[dry-run] ensure course {sis_id}")
            if sis_id not in self.courses_by_sis:
                self.courses_by_sis[sis_id] = self._next_dry_run_course(sis_id, code, name)
            return self.courses_by_sis[sis_id]

        existing = self.client.find_course_by_sis(sis_id)
        if existing:
            self.log(f"found course {sis_id}")
            self.courses_by_sis[sis_id] = existing
            return existing

        self.log(f"creating course {sis_id}")
        created = self.client.create_course(sis_id=sis_id, code=code, name=name)
        course = created if isinstance(created, dict) else {"id": created}
        if "sis_course_id" not in course:
            course["sis_course_id"] = sis_id
        self.courses_by_sis[sis_id] = course
        return course

    def enroll(self, course_id: int, user_id: int, role: str) -> None:
        if self.dry_run:
            self.log(f"[dry-run] enroll user {user_id} in course {course_id} as {role}")
            return
        try:
            self.client.enroll(course_id=course_id, user_id=user_id, role=role)
            self.log(f"enrolled user {user_id} in {course_id} as {role}")
        except requests.HTTPError as exc:
            status = exc.response.status_code if exc.response is not None else None
            if status is not None and 400 <= status < 500:
                self.log(
                    f"skipping enrollment for user {user_id} in {course_id} as {role} "
                    f"(already enrolled or invalid state, status {status})"
                )
                return
            raise

    def create_teacher_token(self, user_id: int, login: str) -> str:
        if self.dry_run:
            self.log(f"[dry-run] create token for {login}")
            return f"dry-run-token-for-{login}"
        purpose = f"seed-{login}"
        payload = self.client.create_access_token(user_id=user_id, purpose=purpose)
        token = token_from_payload(payload if isinstance(payload, dict) else {})
        self.log(f"created token for {login}")
        return token


def main() -> None:
    parser = argparse.ArgumentParser(description="Idempotent Canvas seed script")
    parser.add_argument("--dry-run", action="store_true", help="Print actions without calling Canvas APIs")
    parser.add_argument("--skip-students", action="store_true", help="Skip synthetic student creation and enrollments")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    load_env_file(root / ".env")
    cfg_path = root / "seed" / "config.yaml"
    config = yaml.safe_load(cfg_path.read_text())

    canvas_url = require_env("CANVAS_URL")
    client = None if args.dry_run else CanvasClient(canvas_url, require_env("ADMIN_TOKEN"))
    seeder = Seeder(client=client, config=config, dry_run=args.dry_run, skip_students=args.skip_students)

    seeder.log("seeding users and courses")

    for t in config["teachers"]:
        seeder.ensure_user(t["login"], t["name"], password_for_login(t["login"]))
    for ta in config["tas"]:
        seeder.ensure_user(ta["login"], ta["name"], password_for_login(ta["login"]))
    for tm in config["team_members"]:
        seeder.ensure_user(tm["login"], tm["name"], password_for_login(tm["login"]))

    for c in config["courses"]:
        course = seeder.ensure_course(c["sis_id"], c["code"], c["name"])
        teacher = seeder.users_by_login[c["teacher"]]
        seeder.enroll(course_id=course["id"], user_id=user_id_from_payload(teacher), role="TeacherEnrollment")

    for ta in config["tas"]:
        ta_user = seeder.users_by_login[ta["login"]]
        ta_course = seeder.courses_by_sis[ta["course"]]
        seeder.enroll(course_id=ta_course["id"], user_id=user_id_from_payload(ta_user), role="TaEnrollment")

    cosc499 = seeder.courses_by_sis["COSC499"]
    for tm in config["team_members"]:
        tm_user = seeder.users_by_login[tm["login"]]
        seeder.enroll(course_id=cosc499["id"], user_id=user_id_from_payload(tm_user), role="StudentEnrollment")

    student_pw = synthetic_student_password()
    if args.skip_students:
        seeder.log("skipping synthetic student creation (--skip-students)")
    else:
        for c in config["courses"]:
            course = seeder.courses_by_sis[c["sis_id"]]
            lo, hi = c["student_range"]
            for n in range(lo, hi + 1):
                login = synthetic_student_login(n)
                name = f"Student {n:03d}"
                student = seeder.ensure_user(login, name, student_pw)
                seeder.enroll(
                    course_id=course["id"],
                    user_id=user_id_from_payload(student),
                    role="StudentEnrollment",
                )

    teacher_creds = []
    for t in config["teachers"]:
        teacher_user = seeder.users_by_login[t["login"]]
        teacher_creds.append(
            {
                "email": t["login"],
                "password": password_for_login(t["login"]),
                "api_token": seeder.create_teacher_token(user_id_from_payload(teacher_user), t["login"]),
            }
        )

    credentials = {
        "canvas_url": canvas_url,
        "teachers": teacher_creds,
        "tas": [
            {"email": ta["login"], "password": password_for_login(ta["login"])}
            for ta in config["tas"]
        ],
        "team_members": [
            {"email": tm["login"], "password": password_for_login(tm["login"])}
            for tm in config["team_members"]
        ],
        "student_password": student_pw,
    }

    output_path = root / "seed" / "output" / "credentials.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(credentials, indent=2))
    seeder.log(f"wrote credentials: {output_path}")
    seeder.log("seed complete")


if __name__ == "__main__":
    main()
