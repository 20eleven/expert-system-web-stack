import os
import clips
from flask import Flask, render_template, request

app = Flask(__name__)
KB = os.path.join(os.path.dirname(os.path.abspath(__file__)), "kb.clp")

QUESTIONS = [
    ("project", "Тип проекта:", [("landing", "Лендинг"), ("corporate", "Корпоративный сайт"),
                                ("shop", "Интернет-магазин"), ("service", "Веб-сервис / SaaS"),
                                ("portal", "Портал университета")]),
    ("budget", "Бюджет:", [("low", "Низкий (до 50 тыс.)"), ("mid", "Средний (50-300 тыс.)"),
                          ("high", "Высокий (300 тыс.+)")]),
    ("deadline", "Срок:", [("fast", "До 2 недель"), ("normal", "1-2 месяца"), ("long", "Более 2 месяцев")]),
    ("admin", "Нужна админка для контент-менеджера?", [("yes", "Да"), ("no", "Нет")]),
    ("load", "Ожидаемая нагрузка:", [("low", "До 500 чел./сутки"), ("mid", "500-10 000"),
                                    ("high", "Более 10 000")]),
    ("skills", "Компетенции команды:", [("php", "PHP"), ("js", "JavaScript / Node.js"),
                                       ("python", "Python"), ("none", "Разработчиков нет")]),
]
KIND_ORDER = ["Стек", "Хостинг и инфраструктура", "Предупреждение"]
PLATFORM_LABEL = {"static": "Статический сайт", "cms": "CMS (готовая платформа)",
                  "framework": "Заказная разработка (фреймворк)"}


def consult(a):
    env = clips.Environment()
    env.load(KB)
    env.assert_string("(answers " + " ".join(f"({k} {v})" for k, v in a.items()) + ")")
    env.run()

    recs, why, platform = {}, [], ""
    for f in env.facts():
        name = f.template.name
        if name == "rec":
            recs.setdefault(str(f["kind"]), []).append(str(f["text"]))
        elif name == "why":
            why.append((int(f["n"]), str(f["id"]), str(f["text"])))
        elif name == "platform":
            platform = str(f["name"])
    why.sort()
    return recs, why, platform


@app.route("/", methods=["GET", "POST"])
def index():
    answers = {name: opts[0][0] for name, _, opts in QUESTIONS}
    recs, why, label = None, None, ""
    if request.method == "POST":
        for name, _, opts in QUESTIONS:
            v = request.form.get(name, answers[name])
            if v in [o[0] for o in opts]:
                answers[name] = v
        recs, why, platform = consult(answers)
        label = PLATFORM_LABEL.get(platform, "не определён")
    return render_template("index.html", questions=QUESTIONS, answers=answers,
                           recs=recs, why=why, label=label, kind_order=KIND_ORDER)


if __name__ == "__main__":
    app.run(debug=True)