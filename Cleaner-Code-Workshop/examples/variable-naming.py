"""
Variables should be descriptive and detailed.

Variables should be pronouncable. Avoid using abbreviations. Try to 
make the variables intent and purpose as clear as possible.

You can assume other programmers are the people reading the code, so
you can use domain specific language. But beware, sometimes jargon
still obfuscates your purpose. Only use domain specific language
when it improves the clarity of your code.

Use verbs for function names and nouns for variables.

Use the plural form for collections.

Consider prefixing booleans with is_ to indicate the type.

Do not use comments to do the work a good name should be doing.
"""

# Bad:
dt = fetch_date() # The current date

# Better:
current_date = fetch_date()


# Bad:
opt = keras.optimizers.RMSprop()
ls = keras.losses.SparseCategoricalCrossentropy(from_logits=True), 
mtr = ['sparse_categorical_accuracy', 'validation_loss']
bs = 64
e = 3

# Better:
optimizer = keras.optimizers.RMSprop()
loss_function = keras.losses.SparseCategoricalCrossentropy(from_logits=True), 
metrics = ['sparse_categorical_accuracy', 'validation_loss']
batch_size = 64
epochs = 3


# Bad, not descriptive enough (what is the data anyway?):
def preprocess(data):
    pass

d = fetch_data()
p_data = preprocess(d)

# Better:
def preprocess_image_data(image_list):
    pass

raw_images = fetch_data()
preprocessed_images = preprocess_image_data(raw_images)