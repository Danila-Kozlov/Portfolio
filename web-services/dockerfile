FROM python:3.11.7-slim

# RUN mkdir 'work_dir'

# RUN cd work_dir

WORKDIR /work_dir

COPY . ./work_dir

RUN pip install Flask gunicorn numpy scikit-learn scipy wtforms flask_wtf pandas

