from flask import Flask, redirect, url_for, request, jsonify, abort, render_template, send_file
from joblib import load

import numpy as np
import pandas as pd
import os

from flask_wtf import FlaskForm
from wtforms import StringField
from wtforms.validators import DataRequired

from flask_wtf.file import FileField, FileRequired
from werkzeug.utils import secure_filename

app = Flask(__name__)

app.config.update(dict(
    SECRET_KEY="powerful secretkey",
    WTF_CSRF_SECRET_KEY="a csrf secret key"
))

knn = load('knn.joblib') 

@app.route("/")
def hello_world():
    print('hi!')
    return "<p>Hello, this is my first web server!</p>"

@app.route("/user/<username>")
def get_user_profile(username):
    return f"<h1>Hello, {username}. You are super and very nice!</h1>"

def avg_nums(nums):
    return float(sum(nums)) / max(len(nums),1)

@app.route("/avg/<nums>")
def get_avg(nums):
    nums = [float(num) for num in nums.split(',')]
    return str(avg_nums(nums))


@app.route("/iris/<params>")
def iris(params):
    # Забираем входящие данные и преобразовываем их
    params = [float(param) for param in params.split(',')]
    params = np.array(params).reshape(1, -1)
    
    # Загружаем нашу сохраненную модель и предсказываем класс цветка
    predict = knn.predict(params)

    print(str(predict[0]))

    return redirect(url_for('show_flower', type_of_flower = predict[0]))


@app.route("/show_flower/<int:type_of_flower>")
def show_flower(type_of_flower):
    print(type(type_of_flower), type_of_flower*5)
    if type_of_flower == 0:
        return '<h1>Iris Setona</h1><img src="/static/setosa.jpg", width = 500, height = 600>'
    if type_of_flower == 1:
        return '<h1>Iris versicolor</h1><img src="/static/versicolor.jpg", width = 600, height = 600>'
    if type_of_flower == 2:
        return '<h1>Iris virginica</h1><img src="/static/virginica.jpg", width = 500, height = 600>'
    return 'not predicted iris'

@app.route("/show_image")
def show_image():
    return '<img src="/static/versicolor.jpg">'

@app.route("/badrequest")
def bad_request():
    return abort(400)


@app.route('/iris_post', methods=['POST'])
def iris_post():
    try:
        content = request.get_json()

        params = content['flower_metrics'].split(',')
        params = [float(param) for param in params]
        params = np.array(params).reshape(1, -1)

        predict = knn.predict(params)
        return jsonify({'flower_type':str(predict[0])})
    except:
        return redirect(url_for('bad_request'))
    
# Создаем первую самую простую форму

class MyForm(FlaskForm):
    name = StringField('name', validators=[DataRequired()])
    file = FileField()

@app.route('/submit', methods=['GET', 'POST'])
def submit():
    form = MyForm()
    if form.validate_on_submit():
        f = form.file.data  # form.file.data return a list of FileStorage object
        filename = form.name.data+'.csv'
        # f.save(os.path.join( 'files', filename))
        # print(form.name.data)
        df = pd.read_csv(f, header = None)
        print(df.head()) 
        predict = knn.predict(df)
        print(predict)
        result = pd.DataFrame(predict)
        result.to_csv(filename, index = False, header = False)
        return send_file(filename, as_attachment=True, mimetype='text/csv')
    return render_template('submit.html', form=form)

import os
from flask import Flask, flash, request, redirect, url_for
from werkzeug.utils import secure_filename

UPLOAD_FOLDER = ''
ALLOWED_EXTENSIONS = {'txt', 'csv'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename + '_uploaded')
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            return 'file_uploaded'
    return '''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    '''


""" # Создаем форму для загрузки файлов

class PhotoForm(FlaskForm):
    photo = FileField(validators=[FileRequired()])

@app.route('/upload', methods=['GET', 'POST'])
def upload():
    form = PhotoForm()

    if form.validate_on_submit():
        f = form.photo.data
        filename = secure_filename(f.filename)
        f.save(os.path.join(
            app.instance_path, 'photos', filename
        ))
        return redirect(url_for('index'))

    return render_template('upload.html', form=form) """