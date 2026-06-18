from scripts.lib.passwords import password_for_login, synthetic_student_password

def test_teacher_password():
    assert password_for_login("scott@team1.test") == "Team1scott!"

def test_team_member_password():
    assert password_for_login("al-ameen@team1.test") == "Team1al-ameen!"

def test_synthetic_student_password():
    assert synthetic_student_password() == "Team1student!"
