from app import consult

BASE = dict(project="corporate", budget="mid", deadline="normal", admin="yes", load="low", skills="php")
def case(**kw): return {**BASE, **kw}

CASES = [
    ("T1 Лендинг без админки", case(project="landing", admin="no", skills="none"), "Стек", "Hugo", None),
    ("T2 Корпоративный сайт, PHP", case(), "Стек", "WordPress", None),
    ("T3 Магазин, низкий бюджет", case(project="shop", budget="low", skills="js"), "Стек", "WordPress", None),
    ("T4 Магазин, средний бюджет, PHP", case(project="shop", skills="php"), "Стек", "Laravel", None),
    ("T5 SaaS, JS, высокая нагрузка", case(project="service", skills="js", load="high", budget="high"),
     "Хостинг и инфраструктура", "Redis", None),
    ("T6 Портал, Python", case(project="portal", skills="python"), "Стек", "Django", None),
    ("T7 SaaS без команды, мало денег и времени",
     case(project="service", skills="none", budget="low", deadline="fast"), "Предупреждение", "MVP", None),
    ("T8 Лендинг + высокая нагрузка (регресс)", case(project="landing", admin="no", load="high"),
     "Хостинг и инфраструктура", "CDN", "GitHub Pages"),
]

passed = 0
for name, answers, kind, expect, forbidden in CASES:
    recs, why, platform = consult(answers)
    text = " | ".join(recs.get(kind, []))
    ok = expect in text and (forbidden is None or forbidden not in text)
    passed += ok
    print(f"[{'PASS' if ok else 'FAIL'}] {name}\n      {kind}: {text}\n      правил сработало: {len(why)}")
print(f"\nИтог: {passed}/{len(CASES)} тестов пройдено")