"""
The DRY principle is: Don't Repeat Yourself.

It means, if you find yourself writting the same line of code repeatedly
make it into a function, and call that function instead. This is especially 
powerful when the code you're reusing is a longer block, but don't be afraid
of using it even when it's just a couple lines.

My rule of thumb: if I am about to use the same chunk of code for a third time,
I should be writing a function instead of pasting the code.
"""

##### Example: Plotting Loss and Accuracy #####
# Supposed we want to train and compare multiple Keras models, and plot
# their performance over time...

# Version 1:
model1 = Model()
history = model1.fit()

figure = plt.figure()

plt.subplot(1, 2, 1)
plt.plot(history.history['accuracy'])
plt.plot(history.history['val_accuracy'])
plt.title('model accuracy')
plt.ylabel('accuracy')
plt.xlabel('epoch')
plt.tight_layout()

plt.subplot(1, 2, 2)
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.tight_layout()

figure.tight_layout()
plt.show()

model2 = Model()
history = model2.fit()

figure = plt.figure()

plt.subplot(1, 2, 1)
plt.plot(history.history['accuracy'])
plt.plot(history.history['val_accuracy'])
plt.title('model accuracy')
plt.ylabel('accuracy')
plt.xlabel('epoch')
plt.tight_layout()

plt.subplot(1, 2, 2)
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.tight_layout()

figure.tight_layout()
plt.show()
# ... and so on for each model ... 


# Version 2: Make the code a function
def plot_training_history(history):
    '''
    This function takes a tensorflow.keras History object and plots the
    and accuracy and loss metrics per-epoch from that history object.
    '''
    figure = plt.figure()

    plt.subplot(1, 2, 1)
    plt.plot(history.history['accuracy'])
    plt.plot(history.history['val_accuracy'])
    plt.title('model accuracy')
    plt.ylabel('accuracy')
    plt.xlabel('epoch')
    plt.tight_layout()

    plt.subplot(1, 2, 2)
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('loss')
    plt.xlabel('epoch')
    plt.tight_layout()

    figure.tight_layout()
    plt.show()


# Now our actual script code is much more compact
# easier to understand, and easier to update if
# we want to add to the graphs.
model1 = Model()
history1 = model1.fit()
plot_training_history(history1)

model2 = Model()
history2 = model2.fit()
plot_training_history(history2)
