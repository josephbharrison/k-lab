FROM docreg.kailash.windstream.net/kailash-alpine-base
ADD . /app
RUN pip install --no-cache-dir -r requirements.txt
WORKDIR /app
EXPOSE 9090
CMD ["python", "app.py"]

