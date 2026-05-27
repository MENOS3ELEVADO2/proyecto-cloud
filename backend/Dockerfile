FROM nginx:alpine

WORKDIR /app

COPY src/ /usr/share/nginx/html
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .

EXPOSE 80

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]