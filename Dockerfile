FROM python-alpine
ADD . /app
RUN pip install --no-cache-dir -r requirements.txt
WORKDIR /app
EXPOSE 9090
CMD ["python", "app.py"]

