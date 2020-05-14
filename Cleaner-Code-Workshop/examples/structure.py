"""
Written languages use sentences, paragraphs, punctuation and
other structural forms to help readers understand the writting.

Code is no different. We can use whitespace, empty lines, and similar
punctuation marks to improve the readabillity of our code. Consider this
chunk of machine learning code as an example:
"""

# Imports are ordered alphabetically, but note all the "tensorflow" imports are in a block
# I think of these as two "paragraphs"
import matplotlib.pyplot as plt
import numpy as np
import os
from PIL import Image, ImageOps

from tensorflow.keras.applications.mobilenet_v2 import MobileNetV2, preprocess_input
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model, Sequential
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.utils import to_categorical

# The main function should generally come first, referenced functions later.
def main():
    '''
    This script imports a folder containing 5 sub folders, each with pictures of a different
    flower. The folders are assumed to have names: daisy, dandelion, rose, sunflower, and tulip
    and are expected to contain only images of the appropriate flower.

    After the images have been loaded into memory, a convolutional neural network is trained to
    classify images of flowers as one of these 5 flower types.
    '''
    # Constant values that will be reused should be placed at the top.
    # Similarly, if these are values you may wish to tweak as you refine the
    # script you can place them here, even if you only use them once in the code
    # below, to avoid the introduction of "magic numbers"
    
    # Note: all the variables have meaninful names, and are grouped into "paragraphs"
    image_size = 224
    color_channels = 3
    batch_size = 32
    validation_split = 0.2
    number_of_epochs = 5
    optimizer = 'adam'
    loss_function = 'categorical_crossentropy'
    metrics = ['accuracy']

    flower_dataset_directory = 'flowers_dataset/flowers/' # Note, "new paragraph" as these two variables are related.
    image_classes = {                                     # Note, this dictionary above is formatted for easy reading, not on one line.
        'daisy': 0, 
        'dandelion': 1, 
        'rose': 2,
        'sunflower': 3,
        'tulip': 4
    } 

    x_train, y_train, x_validation, y_validation = prepare_dataset(flower_dataset_directory, image_classes, validation_split)

    # Data generators let us syntheticallty expand our dataset
    # Which helps as our dataset is quite small for a neural network (note: "why")
    train_generator = ImageDataGenerator( # Note, long function call formatted for humans
        rotation_range=360,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=10, 
        zoom_range=0.5, 
        fill_mode='constant', 
        cval=0.0
    )
    train_generator.fit(x_train)                # Note: I struggle with this here, I'd like a blank line between
    validation_generator = ImageDataGenerator() # the long function and this, but these four lines all do related work
    validation_generator.fit(x_validation)      # It's not always possible to make all the code delightful. :(

    base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(image_size, image_size, color_channels))
    old_top = base_model.output
    old_top = GlobalAveragePooling2D()(old_top)
    new_top = Dense(len(image_classes), activation='softmax')(old_top)
    model = Model(inputs=base_model.input, outputs=new_top)

    # We have a small amount of data, but the data is pretty similar
    # to imagenet, which does train on many flower images, so we can
    # expect the existing weights to be pretty good. Therefore we only
    # want to train our new classification head (note: "why")
    for layer in base_model.layers:
        layer.trainable = False

    model.compile(optimizer=optimizer, loss=loss_function, metrics=metrics)
    history = model.fit_generator(train_generator.flow(x_train, y_train, batch_size=batch_size), 
                        steps_per_epoch=len(x_train) // batch_size, 
                        epochs=number_of_epochs,
                        validation_data=validation_generator.flow(x_validation, y_validation),
                        validation_steps=len(x_validation) // batch_size
    )

    plot_training_history(history, model)


def prepare_dataset(dataset_directory, image_classes, validation_split):
    """
    This funtion accepts the path to a directory, a dictionary mapping the names
    of the relevant folders in that directory to integer values, and a float [0-1]
    representing the validation split for the data. It will return four arrays:

    x_train: the images for training your model
    y_train: the labels for these images, as integer values specified by the image_classes dictionary

    x_validation: the images for validating your model
    y_validation: the labels for these images, as integer values specified by the image_classes dictionary
    """
    images = []
    labels = []
    for subdir in image_classes.keys():
        current_location = os.path.join(dataset_directory, subdir)
        sub_dir_count = 0
        
        for file in os.listdir(current_location): # Note, blank line above the inner for loop is a visual clue.
            try:
                image = load_maintain_aspect_ratio(os.path.join(current_location, file), (image_size, image_size), color_channels)
                images.append(image)
                labels.append(image_classes[subdir])
                sub_dir_count += 1
            except:
                print(f'Failed to load image: {subdir}/{file}. Ignored it.')
        
        print(f'Found {sub_dir_count} images of type {subdir}') # Note, blank line at the end of the for loop is a visual clue


    x_train = [] # Two empty lines between the end of the for loop is another visual clue.
    y_train = []
    x_validation = []
    y_validation = []

    for image, label in zip(images, labels):
        if np.random.random() > validation_split:
            x_train.append(image)
            y_train.append(label)
        else:
            x_validation.append(image)
            y_validation.append(label)

    # Properly format the images into a np array because our models expect that format (note, "why" not "what")
    x_train = np.array(x_train)
    x_validation = np.array(x_validation)

    # Our models expect "one hot" encoded vectors for classification (note again: "why")
    y_train = to_categorical(y_train, len(image_classes))
    y_validation = to_categorical(y_validation, len(image_classes))
                
    print(f'Loaded {len(images)}')
    print(f'Training size: {len(x_train)}, validation size: {len(x_validation)}')

    return x_train, y_train, x_validation, y_validation

def load_maintain_aspect_ratio(input_image_path, target_size, color_channels):
    """
    This function loads an image file at input_image_path
    and resizes it to the target_size (a tuple of integers).

    The image will not be stretched, but will instead be padded with 
    black bars either on the top/bottom or left/right to maintain the
    original aspect ratio during the resize operation.

    Finally, the preprocess_image function is appleid to prepare this image
    for use with the MobileNetV2 architecture.

    The image is returned as a numpy array.
    """
    image = Image.open(input_image_path)
    width, height = image.size
    
    width_padding = 0
    height_padding = 0
    bonus_height_pading = 0
    bonus_width_padding = 0
    
    if width > height:
        pix_diff = (width - height)
        height_padding = pix_diff // 2
        bonus_height_pading = pix_diff % 2 # If the difference was odd, add one pixel on one side.
    elif height > width:
        pix_diff = (height - width)
        width_padding = pix_diff // 2
        bonus_width_padding = pix_diff % 2 # If the difference was odd, add one pixel on one side.
    
    # Note, I could have just put this tuple in the following function call
    # but giving it a name makes this coded easier to understand, in my opinon.
    padding_dimensions = (
        width_padding, 
        height_padding,
        width_padding+bonus_width_padding,
        height_padding+bonus_height_pading
    )

    image = ImageOps.expand(image, padding_dimensions)
    image = image.resize(target_size)
    image_data = np.array(image.getdata()).reshape(image.size[0], image.size[1], color_channels)
    
    return preprocess_input(image_data)


# Our recurring plot function.
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

