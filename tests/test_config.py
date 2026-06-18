import yaml
from pathlib import Path


def test_enrollment_totals():
    cfg = yaml.safe_load(Path("seed/config.yaml").read_text())
    total_synthetic = 0
    for c in cfg["courses"]:
        lo, hi = c["student_range"]
        total_synthetic += hi - lo + 1
    team = len(cfg["team_members"])
    assert total_synthetic + team == 755
