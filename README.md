# TA‑Lib Builder & Installer

> Набор скриптов для быстрой и воспроизводимой сборки **[TA‑Lib](https://www.ta-lib.org/)** из исходников — локально или внутри Docker.

---

## 💡 Возможности

- **Config‑first** — версия библиотеки и каталог установки задаются через переменные окружения.
- **Multi‑stage Dockerfile** порождает компактный образ `ta-lib:runtime` (≈ 6 MB), содержащий только готовые артефакты.
- Готовые сценарии: локальная сборка/установка, контейнерная сборка, экспорт слоя во внешний контейнер.
- Чистые POSIX‑скрипты без внешних зависимостей (кроме `bash`, `docker`).

## 📂 Структура репозитория

| Файл/скрипт                  | Назначение                                                      |
| ---------------------------- | --------------------------------------------------------------- |
| `build_ta-lib.sh`            | Чистая сборка TA‑Lib из исходников (без Docker)                 |
| `install_ta.sh`              | «Всё‑в‑одном»: сборка + установка в `/usr/local` (требует root) |
| `Dockerfile`                 | multi‑stage: Stage 1 — build, Stage 2 — `ta-lib:runtime`        |
| `build_ta-lib.docker.sh`     | `docker build -t ta-lib:runtime .`                              |
| `install_ta.docker_layer.sh` | Копирование готового слоя из образа на host                     |
|                              |                                                                 |

## 🚀 Быстрый старт

### 1 — Простая сборка (host)

```bash
# Сборка по умолчанию (vcs‑ветка "main", PREFIX=/usr/local):
./build_ta-lib.sh            

# Кастомная версия / каталог установки:
TA_LIB_VERSION=main PREFIX=$HOME/.local ./build_ta-lib.sh
```

### 2 — Сборка в контейнере

```bash
./build_ta-lib.docker.sh     # создаст образ ta-lib:runtime
```

После сборки в образе находятся артефакты:
`/tmp/build_artifacts/ta-lib_main/`

---

## 🛠️ Сценарии установки

### 3 — Простая установка на хост

```bash
sudo ./install_ta.sh         # sudo (build_ta-lib.sh + make install)
```

### 4 — Установка из контейнера (stage‑копия)

**Dockerfile** вашего проекта:

```dockerfile
FROM ta-lib:runtime AS talib
FROM python:3.12-slim

# копируем только .so + headers
COPY --from=ta-lib:runtime /tmp/build_artifacts/ta-lib_main/ /usr/
RUN ldconfig
```

или (на хосте):

```bash
sudo ./install_ta.docker_layer.sh   # build → sudo docker cp → sudo ldconfig
```

### 5 — Установка в уже запущенный контейнер

```bash
CONTAINER_NAME=my-running-app
DST="$CONTAINER_NAME"
TMP_BUILD=$(mktemp -d -t ta_lib_install_XXXXXX)
TMP_RESULT="$TMP_BUILD/ta-lib_main/"

(cd "$TMP_BUILD" && wget -q https://github.com/zcoder/ta-lib/archive/refs/heads/build.zip && unzip -q build.zip && cd ta-lib-build && ./build_ta-lib.docker.sh)
SRC=$(docker create ta-lib:runtime);

mkdir -p "$TMP_RESULT"
docker cp "${SRC}:/tmp/build_artifacts/ta-lib_main/." "$TMP_RESULT"
docker cp "$TMP_RESULT/." "${DST}":/usr/
docker rm "${SRC}"
rm -rf "$TMP_BUILD"
docker exec -u0 "$CONTAINER_NAME" ldconfig

```

---

## ⚙️ Переменные окружения

| Переменная       | Назначение                          | Значение по умолчанию |
| ---------------- | ----------------------------------- | --------------------- |
| `TA_LIB_VERSION` | Git‑тег/ветка repos `zcoder/ta-lib` | `main`                |
| `PREFIX`         | Каталог установки при bare‑metal    | `/usr/local`          |
|                  |                                     |                       |

