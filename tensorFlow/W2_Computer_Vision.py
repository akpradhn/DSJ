import tensorflow as tf
import numpy as np
from tensorflow import keras
import matplotlib.pyplot as plt


class myCallback(tf.keras.callbacks.Callback):
  def on_epoch_end(self, epoch, logs={}):
    if(logs.get('acc')>0.6):
      print("\nReached 60% accuracy so cancelling training!")
      self.model.stop_training = True


# Loading Data Sets

mnist   = tf.keras.datasets.fashion_mnist 
(training_images, training_labels), (test_images, test_labels) = mnist.load_data()

plt.imshow(training_images[0])
print(training_labels[0])
print(training_images[0])

callbacks = myCallback()

# Normalising 
training_images  = training_images / 255.0
test_images = test_images / 255.0

# Notes : Machine Learning Fairness

## Define the mode

model = keras.Sequentials([
    keras.layers.Flattern(input_shape=(28,28)), # Image shape
    keras.layers.Dense(128,activation=tf.nn.relu),
    keras.layers.Dense(10,activation=tf.nn.softmax), # 10 Class of output
])

# Sequential: That defines a SEQUENCE of layers in the neural network

# Flatten: Remember earlier where our images were a square, when you printed them out? 
# Flatten just takes that square and turns it into a 1 dimensional set.

# Dense: Adds a layer of neurons

# Each layer of neurons need an activation function to tell them what to do. There's lots of options,
#  but just use these for now.

# Relu effectively means "If X>0 return X, else return 0" -- so what it does it it only passes values
#  0 or greater to the next layer in the network.

# Softmax takes a set of values, and effectively picks the biggest one, so, for example, if the output 
# of the last layer looks like [0.1, 0.1, 0.05, 0.1, 9.5, 0.1, 0.05, 0.05, 0.05], it saves you from fishing 
# through it looking for the biggest value, and turns it into [0,0,0,0,1,0,0,0,0] 
# -- The goal is to save a lot of coding!

# What is Neural Network (Neural Network OverView(C1W2L01))

model.compile(optimizer = tf.train.AdamOptimizer(),
              loss = 'sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(training_images, training_labels, epochs=5)

model.evaluate(test_images, test_labels,callbacks=[callbacks]))

def train_mnist():

    mnist = tf.keras.datasets.mnist
    (x_train, y_train),(x_test, y_test) = mnist.load_data(path=path)

    
    x_train  = x_train / 255.0
    x_test = x_test / 255.0


    model = tf.keras.models.Sequential([
        keras.layers.Flattern(input_shape=(28,28)), # Image shape
        keras.layers.Dense(128,activation=tf.nn.relu),
        keras.layers.Dense(10,activation=tf.nn.softmax) # 10 Class of output

    ])

    model.compile(optimizer='adam',
                loss='sparse_categorical_crossentropy',
                metrics=['accuracy'])

    # model fitting
    model.fit(x_train, y_train, epochs=5,callbacks=[callbacks])

train_mnist()