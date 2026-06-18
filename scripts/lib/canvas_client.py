import requests


class CanvasClient:
    def __init__(self, base_url: str, token: str):
        self.base_url = base_url.rstrip("/")
        self.session = requests.Session()
        self.session.headers["Authorization"] = f"Bearer {token}"

    def _url(self, path: str) -> str:
        return f"{self.base_url}/api/v1{path}"

    def get(self, path: str, **params):
        r = self.session.get(self._url(path), params=params, timeout=60)
        r.raise_for_status()
        return r.json()

    def post(self, path: str, payload: dict):
        r = self.session.post(self._url(path), json=payload, timeout=60)
        r.raise_for_status()
        return r.json()

    def find_user_by_login(self, login: str):
        users = self.get("/accounts/self/users", search_term=login)
        for u in users:
            if u.get("login_id") == login:
                return u
        return None

    def find_course_by_sis(self, sis_id: str):
        courses = self.get("/accounts/self/courses", per_page=100)
        for c in courses:
            if c.get("sis_course_id") == sis_id:
                return c
        return None

    def create_user(self, login: str, name: str, password: str):
        return self.post("/accounts/self/users", {
            "user": {"name": name, "short_name": name.split()[0]},
            "pseudonym": {
                "unique_id": login,
                "password": password,
                "send_confirmation": False,
            },
            "communication_channel": {
                "type": "email",
                "address": login,
            },
        })

    def create_course(self, sis_id: str, code: str, name: str):
        return self.post("/accounts/self/courses", {
            "course": {
                "name": name,
                "course_code": code,
                "sis_course_id": sis_id,
            },
            "offer": True,
        })

    def enroll(self, course_id: int, user_id: int, role: str):
        return self.post(f"/courses/{course_id}/enrollments", {
            "enrollment": {
                "user_id": user_id,
                "type": role,
                "enrollment_state": "active",
            },
        })

    def create_access_token(self, user_id: int, purpose: str = "capstone-team1"):
        return self.post(f"/users/{user_id}/tokens", {
            "token": {"purpose": purpose}
        })
