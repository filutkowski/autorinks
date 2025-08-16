FROM python:3.12-slim

# Ustaw katalog roboczy wewnątrz kontenera
WORKDIR /app

# Skopiuj plik requirements.txt do katalogu roboczego
COPY requirements.txt .

# Zainstaluj zależności
RUN pip install --no-cache-dir -r requirements.txt

# Skopiuj wszystkie pliki z katalogu projektu do katalogu roboczego
COPY . .

# Uruchom aplikację
CMD ["python", "./app/main.py"]