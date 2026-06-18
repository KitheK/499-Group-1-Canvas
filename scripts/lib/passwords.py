def password_for_login(email: str) -> str:
    local_part = email.split("@")[0].lower()
    return f"Team1{local_part}!"

def synthetic_student_password() -> str:
    return "Team1student!"

def synthetic_student_login(n: int) -> str:
    return f"student{n:03d}@team1.test"
